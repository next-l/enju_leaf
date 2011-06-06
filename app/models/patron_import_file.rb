class PatronImportFile < ActiveRecord::Base
  include ImportFile
  default_scope :order => 'id DESC'
  scope :not_imported, where(:state => 'pending', :imported_at => nil)
  scope :stucked, where('created_at < ? AND state = ?', 1.hour.ago, 'pending')

  if configatron.uploaded_file.storage == :s3
    has_attached_file :patron_import, :storage => :s3, :s3_credentials => "#{Rails.root.to_s}/config/s3.yml",
      :path => "patron_import_files/:id/:filename"
  else
    has_attached_file :patron_import, :path => ":rails_root/private:url"
  end
  validates_attachment_content_type :patron_import, :content_type => ['text/csv', 'text/plain', 'text/tab-separated-values', 'application/octet-stream']
  validates_attachment_presence :patron_import
  belongs_to :user, :validate => true
  has_many :patron_import_results

  before_create :set_digest

  state_machine :initial => :pending do
    event :sm_start do
      transition [:pending, :started] => :started
    end

    event :sm_complete do
      transition :started => :completed
    end

    event :sm_fail do
      transition :started => :failed
    end
  end

  def set_digest(options = {:type => 'sha1'})
    if File.exists?(patron_import.queued_for_write[:original])
      self.file_hash = Digest::SHA1.hexdigest(File.open(patron_import.queued_for_write[:original].path, 'rb').read)
    end
  end

  def import_start
    sm_start!
    case edit_mode
    when 'create'
      import
    when 'update'
      modify
    when 'destroy'
      remove
    else
      import
    end
  end

  def import
    self.reload
    num = {:patron_imported => 0, :user_imported => 0, :failed => 0}
    row_num = 2
    rows = open_import_file
    field = rows.first
    if [field['first_name'], field['last_name'], field['full_name']].reject{|field| field.to_s.strip == ""}.empty?
      raise "You should specify first_name, last_name or full_name in the first line"
    end
    #rows.shift
    rows.each do |row|
      next if row['dummy'].to_s.strip.present?
      import_result = PatronImportResult.create!(:patron_import_file => self, :body => row.fields.join("\t"))

      begin
        patron = Patron.new
        patron = set_value(patron, row)

        if patron.save!
          import_result.patron = patron
          num[:patron_imported] += 1
          if row_num % 50 == 0
            Sunspot.commit
            GC.start
          end
        end
      rescue
        Rails.logger.info("patron import failed: column #{row_num}")
        num[:failed] += 1
      end

      unless row['username'].to_s.strip.blank?
        begin
          user = User.new
          user.patron = patron
          user.username = row['username'].to_s.strip
          user.email = row['email'].to_s.strip
          user.email_confirmation = user.email
          user.user_number = row['user_number'].to_s.strip
          user.password = row['password'].to_s.strip
          user.password_confirmation = row['password'].to_s.strip
          if user.password.blank?
            user.set_auto_generated_password
          end
          user.operator = User.find('admin')
          library = Library.where(:name => row['library_short_name'].to_s.strip).first || Library.web
          user_group = UserGroup.where(:name => row['user_group_name']).first || UserGroup.first
          user.library = library
          role = Role.where(:name => row['role'].to_s.strip.camelize).first || Role.find('User')
          user.role = role
          user.required_role = patron.required_role
          user.locale = patron.language.try(:iso_639_1) || I18n.default_locale.to_s
          if user.save!
            import_result.user = user
          end
          num[:user_imported] += 1
        rescue ActiveRecord::RecordInvalid
          Rails.logger.info("user import failed: column #{row_num}")
        end
      end

      import_result.save!
      row_num += 1
    end
    self.update_attribute(:imported_at, Time.zone.now)
    Sunspot.commit
    rows.close
    sm_complete!
    return num
  end

  def self.import
    PatronImportFile.not_imported.each do |file|
      file.import_start
    end
  rescue
    logger.info "#{Time.zone.now} importing patrons failed!"
  end

  def modify
    rows = self.open_import_file
    field = rows.first
    rows.each do |row|
      patron = Patron.where(:id => row['patron_id'].to_s.strip).first
      if patron
        set_value(patron, row)
        patron.save
      end
    end
  end

  def remove
    rows = self.open_import_file
    field = rows.first
    rows.each do |row|
      patron = Patron.where(:id => row['patron_id'].to_s.strip).first
      if patron
        patron.destroy
      end
    end
  end

  private
  def open_import_file
    tempfile = Tempfile.new('patron_import_file')
    if configatron.uploaded_file.storage == :s3
      uploaded_file_path = open(self.patron_import.url).path
    else
      uploaded_file_path = self.patron_import.path
    end
    open(uploaded_file_path){|f|
      f.each{|line|
        tempfile.puts(NKF.nkf('-w -Lu', line))
      }
    }

    tempfile.open
    if RUBY_VERSION > '1.9'
      file = CSV.open(tempfile, :col_sep => "\t")
      header = file.first
      rows = CSV.open(tempfile, :headers => header, :col_sep => "\t")
    else
      file = FasterCSV.open(tempfile, :col_sep => "\t")
      header = file.first
      rows = FasterCSV.open(tempfile, :headers => header, :col_sep => "\t")
    end
    PatronImportResult.create(:patron_import_file => self, :body => header.join("\t"))
    tempfile.close
    file.close
    rows
  end

  def set_value(patron, row)
    patron.first_name = row['first_name']
    patron.middle_name = row['middle_name']
    patron.last_name = row['last_name']
    patron.first_name_transcription = row['first_name_transcription']
    patron.middle_name_transcription = row['middle_name_transcription']
    patron.last_name_transcription = row['last_name_transcription']

    patron.full_name = row['full_name']
    patron.full_name_transcription = row['full_name_transcription']

    patron.address_1 = row['address_1']
    patron.address_2 = row['address_2']
    patron.zip_code_1 = row['zip_code_1']
    patron.zip_code_2 = row['zip_code_2']
    patron.telephone_number_1 = row['telephone_number_1']
    patron.telephone_number_2 = row['telephone_number_2']
    patron.fax_number_1 = row['fax_number_1']
    patron.fax_number_2 = row['fax_number_2']
    patron.note = row['note']
    patron.birth_date = row['birth_date']
    patron.death_date = row['death_date']

    if row['username'].to_s.strip.blank?
      patron.email = row['email'].to_s.strip
      patron.required_role = Role.where(:name => row['required_role_name'].to_s.strip.camelize).first || Role.find('Guest')
    else
      patron.required_role = Role.where(:name => row['required_role_name'].to_s.strip.camelize).first || Role.find('Librarian')
    end
    language = Language.where(:name => row['language'].to_s.strip.camelize).first
    language = Language.where(:iso_639_2 => row['language'].to_s.strip.downcase).first unless language
    language = Language.where(:iso_639_1 => row['language'].to_s.strip.downcase).first unless language
    patron.language = language if language
    country = Country.where(:name => row['country'].to_s.strip).first
    patron.country = country if country
    patron
  end
end
