class EventImportFile < ActiveRecord::Base
  default_scope :order => 'id DESC'
  scope :not_imported, :conditions => {:state => 'pending', :imported_at => nil}

  has_attached_file :event_import, :path => ":rails_root/private:url"
  validates_attachment_content_type :event_import, :content_type => ['text/csv', 'text/plain', 'text/tab-separated-values', 'application/octet-stream']
  validates_attachment_presence :event_import
  belongs_to :user, :validate => true
  has_many :imported_objects, :as => :imported_file, :dependent => :destroy
  #after_create :set_digest

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
    self.file_hash = Digest::SHA1.hexdigest(File.open(self.event_import.path, 'rb').read)
    save(:validate => false)
  end

  def import_start
    sm_start!
    import
  end

  def import
    unless /text\/.+/ =~ FileWrapper.get_mime(event_import.path)
      sm_fail!
      raise 'Invalid format'
    end
    self.reload
    num = {:success => 0, :failure => 0}
    record = 2
    if RUBY_VERSION > '1.9'
      file = CSV.open(self.event_import.path, :col_sep => "\t")
      rows = CSV.open(self.event_import.path, :headers => file.first, :col_sep => "\t")
    else
      file = FasterCSV.open(self.event_import.path, :col_sep => "\t")
      rows = FasterCSV.open(self.event_import.path, :headers => file.first, :col_sep => "\t")
    end
    file.close
    field = rows.first
    if [field['name']].reject{|f| f.to_s.strip == ""}.empty?
      raise "You should specify a name in the first line"
    end
    if [field['start_at'], field['end_at'], field['all_day']].reject{|field| field.to_s.strip == ""}.empty?
      raise "You should specify dates in the first line"
    end
    #rows.shift
    rows.each do |row|
      event = Event.new
      event.name = row['name']
      event.note = row['note']
      event.start_at = row['start_at']
      event.end_at = row['end_at']
      category = row['category']
      unless row['all_day'].to_s.strip.blank?
        all_day = true
      end
      library = Library.first(:conditions => {:name => row['library_short_name']})
      library = Library.web if library.blank?
      event.library = library
      if category == "closed"
        event.event_category = EventCagetory.first(:conditions => {:name => 'closed'})
      end

      begin
        if event.save!
          imported_object = ImportedObject.new
          imported_object.importable = event
          self.imported_objects << imported_object
          num[:success] += 1
          GC.start if record % 50 == 0
        end
      rescue
        Rails.logger.info("event import failed: column #{record}")
        num[:failure] += 1
      end
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

end
