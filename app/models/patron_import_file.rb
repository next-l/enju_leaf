class PatronImportFile < ActiveRecord::Base
  default_scope :order => 'id DESC'
  scope :not_imported, :conditions => {:state => 'pending', :imported_at => nil}

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

  validates_associated :user
  validates_presence_of :user
  before_create :set_digest

  state_machine :initial => :pending do
    event :sm_start do
      transition :pending => :started
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
    import
  end

  def import
    self.reload
    num = {:success => 0, :failure => 0, :activated => 0}
    row_num = 2
    if RUBY_VERSION > '1.9'
      if configatron.uploaded_file.storage == :s3
        file = CSV.open(open(self.patron_import.url).path, :col_sep => "\t")
        header = file.first
        rows = CSV.open(open(self.patron_import.url).path, :headers => header, :col_sep => "\t")

      else
        file = CSV.open(self.patron_import.path, :col_sep => "\t")
        header = file.first
        rows = CSV.open(self.patron_import.path, :headers => header, :col_sep => "\t")
      end
    else
      if configatron.uploaded_file.storage == :s3
        file = FasterCSV.open(open(self.patron_import.url).path, :col_sep => "\t")
        header = file.first
        rows = FasterCSV.open(open(self.patron_import.url).path, :headers => header, :col_sep => "\t")
      else
        file = FasterCSV.open(self.patron_import.path, :col_sep => "\t")
        header = file.first
        rows = FasterCSV.open(self.patron_import.path, :headers => header, :col_sep => "\t")
      end
    end
    PatronImportResult.create!(:patron_import_file => self, :body => header.join("\t"))
    file.close
    field = rows.first
    if [field['first_name'], field['last_name'], field['full_name']].reject{|field| field.to_s.strip == ""}.empty?
      raise "You should specify first_name, last_name or full_name in the first line"
    end
    #rows.shift
    rows.each do |row|
      import_result = PatronImportResult.create!(:patron_import_file => self, :body => row.fields.join("\t"))

      begin
        patron = Patron.new
        patron.first_name = row['first_name']
        patron.middle_name = row['middle_name']
        patron.last_name = row['last_name']
        patron.first_name_transcription = row['first_name_transcription']
        patron.middle_name_transcription = row['middle_name_transcription']
        patron.last_name_transcription = row['last_name_transcription']

        patron.full_name = row['full_name']
        patron.full_name_transcription = row['full_name_transcription']
        patron.full_name = row['last_name'] + row['middle_name'] + row['first_name'] if patron.full_name.blank?

        patron.address_1 = row['address_1']
        patron.address_2 = row['address_2']
        patron.zip_code_1 = row['zip_code_1']
        patron.zip_code_2 = row['zip_code_2']
        patron.telephone_number_1 = row['telephone_number_1']
        patron.telephone_number_2 = row['telephone_number_2']
        patron.fax_number_1 = row['fax_number_1']
        patron.fax_number_2 = row['fax_number_2']
        patron.note = row['note']
        country = Country.find_by_name(row['country'])
        patron.country = country if country.present?

        if patron.save!
          import_result.patron = patron
          num[:success] += 1
          if row_num % 50 == 0
            Sunspot.commit
            GC.start
          end
        end
      rescue
        Rails.logger.info("patron import failed: column #{row_num}")
        num[:failure] += 1
      end

      unless row['username'].blank?
        begin
          user = User.new
          user.patron = patron
          user.username = row['username'].to_s.strip
          user.email = row['email'].to_s.strip
          user.email_confirmation = row['email'].to_s.strip
          user.user_number = row['user_number'].to_s.strip
          user.password = row['password'].to_s.strip
          user.password_confirmation = row['password'].to_s.strip
          if user.password.blank?
            user.set_auto_generated_password
          end
          user.operator = User.find('admin')
          library = Library.first(:conditions => {:name => row['library_short_name'].to_s.strip}) || Library.web
          user_group = UserGroup.first(:conditions => {:name => row['user_group_name']}) || UserGroup.first
          user.library = library
          role = Role.first(:conditions => {:name => row['role']}) || Role.find(2)
          user.role = role
          if user.save!
            import_result.user = user
          end
          num[:activated] += 1
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
end
