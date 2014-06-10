class UserImportFile < ActiveRecord::Base
  attr_accessible :user_import, :edit_mode
  include ImportFile
  default_scope {order('user_import_files.id DESC')}
  scope :not_imported, -> {where(:state => 'pending')}
  scope :stucked, -> {where('created_at < ? AND state = ?', 1.hour.ago, 'pending')}

  if Setting.uploaded_file.storage == :s3
    has_attached_file :user_import, :storage => :s3,
      :s3_credentials => "#{Setting.amazon}",
      :s3_permissions => :private
  else
    has_attached_file :user_import,
      :path => ":rails_root/private/system/:class/:attachment/:id_partition/:style/:filename"
  end
  validates_attachment_content_type :user_import, :content_type => [
    'text/csv',
    'text/plain',
    'text/tab-separated-values',
    'application/octet-stream',
    'application/vnd.ms-excel'
  ]
  validates_attachment_presence :user_import
  belongs_to :user, :validate => true
  has_many :user_import_results

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

    before_transition any => :started do |user_import_file|
      user_import_file.executed_at = Time.zone.now
    end

    before_transition any => :completed do |user_import_file|
      user_import_file.error_message = nil
    end
  end

  def import_start
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
    sm_start!
    reload
    num = {:user_imported => 0, :user_found => 0, :failed => 0}
    rows = open_import_file
    row_num = 2

    field = rows.first
    if [field['username']].reject{|field| field.to_s.strip == ""}.empty?
      raise "username column is not found"
    end

    rows.each do |row|
      next if row['dummy'].to_s.strip.present?
      import_result = UserImportResult.create!(
        :user_import_file_id => id, :body => row.fields.join("\t")
      )

      username = row['username']
      new_user = User.where(:username => username).first
      if new_user
        import_result.user = new_user
        import_result.save
        num[:user_found] += 1
      else
        new_user = User.new
        new_user.operator = user
        new_user.username = username
        new_user.email = row['email'] if row['email'].present?
        new_user.role = Role.where(:name => row['role']).first
        unless new_user.role
          new_user.role = Role.find(2) # User
        end
        if row['user_group'].present?
          new_user.user_group = UserGroup.where(:name => row['user_group']).first
        end
        new_user.user_number = row['user_number']
        if row['expired_at'].present?
          new_user.expired_at = Time.zone.parse(row['expired_at']).end_of_day
        end
        new_user.note = row['note']
        if row['password'].present?
          new_user.password = row['password']
        else
          new_user.set_auto_generated_password
        end

        if new_user.save!
          num[:user_imported] += 1
          import_result.user = new_user
          import_result.save!
        else
          num[:failed] += 1
        end
      end
    end

    rows.close
    sm_complete!
    Sunspot.commit
    num
  rescue => e
    self.error_message = "line #{row_num}: #{e.message}"
    sm_fail!
    raise e
  end

  def modify
    sm_start!
    sm_complete!
  end

  def remove
    sm_start!
    reload
    rows = open_import_file

    field = rows.first
    if [field['username']].reject{|field| field.to_s.strip == ""}.empty?
      raise "username column is not found"
    end

    rows.each do |row|
      username = row['username'].to_s.strip
      user = User.where(:username => username).first
      user.destroy if user
    end
    sm_complete!
  end

  private
  def open_import_file
    tempfile = Tempfile.new('user_import_file')
    if Setting.uploaded_file.storage == :s3
      uploaded_file_path = user_import.expiring_url(10)
    else
      uploaded_file_path = user_import.path
    end
    open(uploaded_file_path){|f|
      f.each{|line|
        if defined?(CharlockHolmes::EncodingDetector)
          begin
            string = line.encode('UTF-8', CharlockHolmes::EncodingDetector.detect(line)[:encoding], universal_newline: true)
          rescue StandardError
            string = NKF.nkf('-w -Lu', line)
          end
        else
          string = NKF.nkf('-w -Lu', line)
        end
        tempfile.puts(string)
      }
    }
    tempfile.close

    file = CSV.open(tempfile.path, 'r:utf-8', :col_sep => "\t")
    header = file.first
    rows = CSV.open(tempfile.path, 'r:utf-8', :headers => header, :col_sep => "\t")
    UserImportResult.create!(:user_import_file_id => self.id, :body => header.join("\t"))
    tempfile.close(true)
    file.close
    rows
  end

  def self.import
    UserImportFile.not_imported.each do |file|
      file.import_start
    end
  rescue
    Rails.logger.info "#{Time.zone.now} importing resources failed!"
  end
end
