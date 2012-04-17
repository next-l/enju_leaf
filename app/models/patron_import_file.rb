class PatronImportFile < ActiveRecord::Base
  include ImportFile
  default_scope :order => 'id DESC'
  scope :not_imported, where(:state => 'pending')
  scope :stucked, where('created_at < ? AND state = ?', 1.hour.ago, 'pending')

  if configatron.uploaded_file.storage == :s3
    has_attached_file :patron_import, :storage => :s3, :s3_credentials => "#{Rails.root.to_s}/config/s3.yml",
      :path => "patron_import_files/:id/:filename",
      :s3_permissions => :private
  else
    has_attached_file :patron_import, :path => ":rails_root/private:url"
  end
  validates_attachment_content_type :patron_import, :content_type => ['text/csv', 'text/plain', 'text/tab-separated-values', 'application/octet-stream']
  validates_attachment_presence :patron_import
  belongs_to :user, :validate => true
  has_many :patron_import_results

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

    before_transition any => :started do |patron_import_file|
      patron_import_file.executed_at = Time.zone.now
    end

    before_transition any => :completed do |patron_import_file|
      patron_import_file.error_message = nil
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

      patron = Patron.new
      patron = set_patron_value(patron, row)

      if patron.save!
        import_result.patron = patron
        num[:patron_imported] += 1
        if row_num % 50 == 0
          Sunspot.commit
          GC.start
        end
      end

      #unless row['username'].to_s.strip.blank?
      #  user = User.new
      #  user.patron = patron
      #  set_user_value(user, row)
      #  if user.password.blank?
      #    user.set_auto_generated_password
      #  end
      #  if user.save!
      #    import_result.user = user
      #  end
      #  num[:user_imported] += 1
      #end

      import_result.save!
      row_num += 1
    end
    Sunspot.commit
    rows.close
    sm_complete!
    return num
  rescue => e
    self.error_message = "line #{row_num}: #{e.message}"
    sm_fail!
    raise e
  end

  def self.import
    PatronImportFile.not_imported.each do |file|
      file.import_start
    end
  rescue
    Rails.logger.info "#{Time.zone.now} importing patrons failed!"
  end

  def modify
    sm_start!
    rows = open_import_file
    row_num = 2

    rows.each do |row|
      next if row['dummy'].to_s.strip.present?
      #user = User.where(:user_number => row['user_number'].to_s.strip).first
      #if user.try(:patron)
      #  set_patron_value(user.patron, row)
      #  user.patron.save!
      #  set_user_value(user, row)
      #  user.save!
      #end
      patron = Patron.where(:id => row['id']).first
      if patron
        patron.full_name = row['full_name'] if row['full_name'].to_s.strip.present?
        patron.full_name_transcription = row['full_name_transcription'] if row['full_name_transcription'].to_s.strip.present?
        patron.first_name = row['first_name'] if row['first_name'].to_s.strip.present?
        patron.first_name_transcription = row['first_name_transcription'] if row['first_name_transcription'].to_s.strip.present?
        patron.middle_name = row['middle_name'] if row['middle_name'].to_s.strip.present?
        patron.middle_name_transcription = row['middle_name_transcription'] if row['middle_name_transcription'].to_s.strip.present?
        patron.last_name = row['last_name'] if row['last_name'].to_s.strip.present?
        patron.last_name_transcription = row['last_name_transcription'] if row['last_name_transcription'].to_s.strip.present?
        patron.address_1 = row['address_1'] if row['address_1'].to_s.strip.present?
        patron.address_2 = row['address_2'] if row['address_2'].to_s.strip.present?
        patron.save!
      end
      row_num += 1
    end
    sm_complete!
  rescue => e
    self.error_message = "line #{row_num}: #{e.message}"
    sm_fail!
    raise e
  end

  def remove
    sm_start!
    rows = open_import_file
    row_num = 2

    rows.each do |row|
      next if row['dummy'].to_s.strip.present?
      patron = Patron.where(:id => row['id'].to_s.strip).first
      if patron
        patron.destroy
      end
      row_num += 1
    end
    sm_complete!
  rescue => e
    self.error_message = "line #{row_num}: #{e.message}"
    sm_fail!
    raise e
  end

  private
  def open_import_file
    tempfile = Tempfile.new('patron_import_file')
    if configatron.uploaded_file.storage == :s3
      uploaded_file_path = patron_import.expiring_url(10)
    else
      uploaded_file_path = patron_import.path
    end
    open(uploaded_file_path){|f|
      f.each{|line|
        tempfile.puts(NKF.nkf('-w -Lu', line))
      }
    }
    tempfile.close

    file = CSV.open(tempfile, :col_sep => "\t")
    header = file.first
    rows = CSV.open(tempfile, :headers => header, :col_sep => "\t")
    PatronImportResult.create(:patron_import_file => self, :body => header.join("\t"))
    tempfile.close(true)
    file.close
    rows
  end

  def set_patron_value(patron, row)
    patron.first_name = row['first_name'] if row['first_name']
    patron.middle_name = row['middle_name'] if row['middle_name']
    patron.last_name = row['last_name'] if row['last_name']
    patron.first_name_transcription = row['first_name_transcription'] if row['first_name_transcription']
    patron.middle_name_transcription = row['middle_name_transcription'] if row['middle_name_transcription']
    patron.last_name_transcription = row['last_name_transcription'] if row['last_name_transcription']

    patron.full_name = row['full_name'] if row['full_name']
    patron.full_name_transcription = row['full_name_transcription'] if row['full_name_transcription']

    patron.address_1 = row['address_1'] if row['address_1']
    patron.address_2 = row['address_2'] if row['address_2']
    patron.zip_code_1 = row['zip_code_1'] if row['zip_code_1']
    patron.zip_code_2 = row['zip_code_2'] if row['zip_code_2']
    patron.telephone_number_1 = row['telephone_number_1'] if row['telephone_number_1']
    patron.telephone_number_2 = row['telephone_number_2'] if row['telephone_number_2']
    patron.fax_number_1 = row['fax_number_1'] if row['fax_number_1']
    patron.fax_number_2 = row['fax_number_2'] if row['fax_number_2']
    patron.note = row['note'] if row['note']
    patron.birth_date = row['birth_date'] if row['birth_date']
    patron.death_date = row['death_date'] if row['death_date']

    #if row['username'].to_s.strip.blank?
      patron.email = row['email'].to_s.strip
      patron.required_role = Role.where(:name => row['required_role_name'].to_s.strip.camelize).first || Role.find('Guest')
    #else
    #  patron.required_role = Role.where(:name => row['required_role_name'].to_s.strip.camelize).first || Role.find('Librarian')
    #end
    language = Language.where(:name => row['language'].to_s.strip.camelize).first
    language = Language.where(:iso_639_2 => row['language'].to_s.strip.downcase).first unless language
    language = Language.where(:iso_639_1 => row['language'].to_s.strip.downcase).first unless language
    patron.language = language if language
    country = Country.where(:name => row['country'].to_s.strip).first
    patron.country = country if country
    patron
  end

  #def set_user_value(user, row)
  #  user.operator = User.find(1)
  #  email = row['email'].to_s.strip
  #  if email.present?
  #    user.email = email
  #    user.email_confirmation = email
  #  end
  #  password = row['password'].to_s.strip
  #  if password.present?
  #    user.password = password
  #    user.password_confirmation = password
  #  end
  #  user.username = row['username'] if row['username']
  #  user.user_number = row['user_number'] if row['user_number']
  #  library = Library.where(:name => row['library_short_name'].to_s.strip).first || Library.web
  #  user_group = UserGroup.where(:name => row['user_group_name']).first || UserGroup.first
  #  user.library = library
  #  role = Role.where(:name => row['role_name'].to_s.strip.camelize).first || Role.find('User')
  #  user.role = role
  #  required_role = Role.where(:name => row['required_role_name'].to_s.strip.camelize).first || Role.find('Librarian')
  #  user.required_role = required_role
  #  locale = Language.where(:iso_639_1 => row['locale'].to_s.strip).first
  #  user.locale = locale || I18n.default_locale.to_s
  #  user
  #end
end

# == Schema Information
#
# Table name: patron_import_files
#
#  id                         :integer         not null, primary key
#  parent_id                  :integer
#  content_type               :string(255)
#  size                       :integer
#  user_id                    :integer
#  note                       :text
#  executed_at                :datetime
#  state                      :string(255)
#  patron_import_file_name    :string(255)
#  patron_import_content_type :string(255)
#  patron_import_file_size    :integer
#  patron_import_updated_at   :datetime
#  created_at                 :datetime        not null
#  updated_at                 :datetime        not null
#  edit_mode                  :string(255)
#  patron_import_fingerprint  :string(255)
#  error_message              :text
#

