class EventImportFile < ActiveRecord::Base
  include ImportFile
  default_scope :order => 'id DESC'
  scope :not_imported, where(:state => 'pending', :imported_at => nil)
  scope :stucked, where('created_at < ? AND state = ?', 1.hour.ago, 'pending')

  if configatron.uploaded_file.storage == :s3
    has_attached_file :event_import, :storage => :s3, :s3_credentials => "#{Rails.root.to_s}/config/s3.yml",
      :path => "event_import_files/:id/:filename",
      :s3_permissions => :private
  else
    has_attached_file :event_import, :path => ":rails_root/private:url"
  end
  validates_attachment_content_type :event_import, :content_type => ['text/csv', 'text/plain', 'text/tab-separated-values', 'application/octet-stream']
  validates_attachment_presence :event_import
  belongs_to :user, :validate => true
  has_many :event_import_results
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
    if File.exists?(event_import.queued_for_write[:original])
      self.file_hash = Digest::SHA1.hexdigest(File.open(event_import.queued_for_write[:original].path, 'rb').read)
    end
  end

  def import_start
    sm_start!
    case edit_mode
    when 'create'
      import
    when 'update'
    when 'destroy'
    else
      import
    end
  end

  def import
    self.reload
    num = {:imported => 0, :failed => 0}
    record = 2

    rows = open_import_file
    field = rows.first
    if [field['name']].reject{|f| f.to_s.strip == ""}.empty?
      raise "You should specify a name in the first line"
    end
    if [field['start_at'], field['end_at']].reject{|field| field.to_s.strip == ""}.empty?
      raise "You should specify dates in the first line"
    end
    #rows.shift
    rows.each do |row|
      next if row['dummy'].to_s.strip.present?
      import_result = EventImportResult.create!(:event_import_file => self, :body => row.fields.join("\t"))

      event = Event.new
      event.name = row['name']
      event.note = row['note']
      event.start_at = row['start_at']
      event.end_at = row['end_at']
      category = row['category'].to_s.strip
      event.all_day = true
      library = Library.where(:name => row['library_short_name']).first
      library = Library.web if library.blank?
      event.library = library
      event_category = EventCategory.where(:name => category).first || EventCategory.where(:name => 'unknown').first
      event.event_category = event_category

      begin
        if event.save!
          import_result.event = event
          num[:imported] += 1
          if record % 50 == 0
            Sunspot.commit
            GC.start
          end
        end
      rescue
        Rails.logger.info("event import failed: column #{record}")
        num[:failed] += 1
      end
      import_result.save!
      record += 1
    end
    self.update_attribute(:imported_at, Time.zone.now)
    Sunspot.commit
    rows.close
    sm_complete!
    return num
  end

  def self.import
    EventImportFile.not_imported.each do |file|
      file.import_start
    end
  rescue
    logger.info "#{Time.zone.now} importing events failed!"
  end

  private
  def open_import_file
    tempfile = Tempfile.new('event_import_file')
    if configatron.uploaded_file.storage == :s3
      uploaded_file_path = open(self.event_import.expiring_url(10)).path
    else
      uploaded_file_path = self.event_import.path
    end
    open(uploaded_file_path){|f|
      f.each{|line|
        tempfile.puts(NKF.nkf('-w -Lu', line))
      }
    }
    tempfile.close

    if RUBY_VERSION > '1.9'
      file = CSV.open(tempfile, :col_sep => "\t")
      header = file.first
      rows = CSV.open(tempfile, :headers => header, :col_sep => "\t")
    else
      file = FasterCSV.open(tempfile.path, :col_sep => "\t")
      header = file.first
      rows = FasterCSV.open(tempfile.path, :headers => header, :col_sep => "\t")
    end
    EventImportResult.create!(:event_import_file => self, :body => header.join("\t"))
    tempfile.close(true)
    file.close
    rows
  end
end

# == Schema Information
#
# Table name: event_import_files
#
#  id                        :integer         not null, primary key
#  parent_id                 :integer
#  content_type              :string(255)
#  size                      :integer
#  file_hash                 :string(255)
#  user_id                   :integer
#  note                      :text
#  imported_at               :datetime
#  state                     :string(255)
#  event_import_file_name    :string(255)
#  event_import_content_type :string(255)
#  event_import_file_size    :integer
#  event_import_updated_at   :datetime
#  created_at                :datetime
#  updated_at                :datetime
#  edit_mode                 :string(255)
#

