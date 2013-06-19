class UserFile
  SEPARATOR = ','

  cattr_accessor :base_dir
  @@base_dir = File.join(Rails.root, 'private', 'user_file')

  cattr_accessor :category
  @@category = {
    # :category_sym => { :expire => sec, :mime_type => 'mime/type' }
    manifestation_list: {
      expire: 24.hours,
    },
    manifestation_list_prepare: {
      expire: 24.hours,
    },
    item_list: {
      expire: 24.hours,
    },
    item_register: {
      expire: 24.hours,
    },
    checkoutlist: {
      expire: 24.hours,
    },
  }

  class << self
    def cleanup!
      now = Time.now

      Dir.glob(path_format%['*', '*', '*', '*']) do |path|
        next unless File.file?(path)

        begin
          info = parse_filename(File.basename(path))
        rescue
          # ignore
          next
        end

        category = self.category[info[:category]]
        next unless category[:expire]

        if File.mtime(path) > now + category[:expire]
          FileUtils.remove_entry_secure(path)
        end
      end
    end

    def path_format
      File.join(base_dir, %w(%s %s %s %s).join(SEPARATOR))
    end

    def parse_filename(str)
      id, category, random, filename = str.split(/#{Regexp.quote(SEPARATOR)}/o, 4)
      id = Integer(id)
      category = category.to_sym

      raise "invalid id: #{id}" unless id > 0
      check_category!(category)
      check_filename!(filename)

      {
        id: id,
        category: category,
        random: random,
        filename: filename
      }
    end

    def check_category!(sym)
      raise ArgumentError, "unknown category: #{sym}" unless category.include?(sym)
    end

    def check_filename!(filename)
      if filename.include?(SEPARATOR) ||
          filename.include?(File::SEPARATOR) ||
          filename.include?('..') ||
          filename.include?('%')
        raise ArgumentError, "invalid filename: #{filename}"
      end
    end
  end

  def initialize(user)
    @user = user
  end
  attr_reader :user

  def create(category, filename, open_option = 'w:binary', &block)
    path, info = generate_path(category, filename)
    FileUtils.mkdir_p(File.dirname(path))
    if block_given?
      open(path, open_option) {|io| yield(io, info) }
    else
      [open(path, open_option), info]
    end
  end

  def find(category, filename, random_segment = nil)
    begin
      pattern = glob_pattern(category, filename, random_segment)
    rescue ArgumentError
      return []
    end

    Dir.glob(pattern).sort_by {|path| File.mtime(path) }
  end

  private

    def random_segment
      "#{Time.now.strftime('%Y%m%d%H%M%S')}#{$$}#{rand(0x100000000).to_s(36)}"
    end

    def glob_pattern(category, filename, random_segment)
      check_category_and_filename!(category, filename)
      if random_segment
        self.class.check_filename!(random_segment)
      else
        random_segment = '*'
      end
      self.class.path_format%[@user.id.to_s, category, random_segment, filename]
    end

    def generate_path(category, filename)
      check_category_and_filename!(category, filename)
      info = {id: @user.id, category: category, random: random_segment, filename: filename}
      path = self.class.path_format%[@user.id.to_s, category, info[:random], filename]

      [path, info]
    end

    def check_category_and_filename!(category, filename)
      self.class.check_category!(category)
      self.class.check_filename!(filename)
    end
end
