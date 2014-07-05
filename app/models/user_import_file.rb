class UserImportFile < ActiveRecord::Base
  attr_accessible :user_import, :edit_mode, :user_encoding, :mode
  include Statesman::Adapters::ActiveRecordModel
  include ImportFile
  default_scope {order('user_import_files.id DESC')}
  scope :not_imported, -> {in_state(:pending)}
  scope :stucked, -> {in_state(:pending).where('created_at < ? AND state = ?', 1.hour.ago)}

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

  has_many :user_import_file_transitions

  enju_import_file_model
  attr_accessor :mode

  def state_machine
    @state_machine ||= UserImportFileStateMachine.new(self, transition_class: UserImportFileTransition)
  end

  delegate :can_transition_to?, :transition_to!, :transition_to, :current_state,
    to: :state_machine

  def import
    transition_to!(:started)
    num = {:user_imported => 0, :user_found => 0, :failed => 0}
    rows = open_import_file(create_import_temp_file)
    row_num = 2

    field = rows.first
    if [field['username']].reject{|f| f.to_s.strip == ""}.empty?
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
        new_user.role = Role.where(:name => row['role']).first
        if new_user.role
          unless user.has_role?(new_user.role.name)
            num[:failed] += 1
            next
          end
        else
          new_user.role = Role.find(2) # User
        end
        new_user.operator = user
        new_user.username = username
        new_user.email = row['email'] if row['email'].present?
        if row['user_group'].present?
          new_user.user_group = UserGroup.where(:name => row['user_group']).first
        end
        new_user.user_number = row['user_number']
        if row['expired_at'].present?
          new_user.expired_at = Time.zone.parse(row['expired_at']).end_of_day
        end
        new_user.note = row['note']

        if I18n.available_locales.include?(row['locale'].to_s.to_sym)
          new_user.locale = row['locale']
        end

        library = Library.where(:name => row['library'].to_s.strip).first || Library.web
        new_user.library = library

        if row['password'].present?
          new_user.password = row['password']
        else
          new_user.set_auto_generated_password
        end

        if new_user.save
          num[:user_imported] += 1
          import_result.user = new_user
          import_result.save!
        else
          num[:failed] += 1
        end
      end
    end

    rows.close
    transition_to!(:completed)
    Sunspot.commit
    num
  rescue => e
    self.error_message = "line #{row_num}: #{e.message}"
    transition_to!(:failed)
    raise e
  end

  def modify
    transition_to!(:started)
    transition_to!(:completed)
  rescue => e
    self.error_message = "line #{row_num}: #{e.message}"
    transition_to!(:failed)
    raise e
  end

  def remove
    transition_to!(:started)
    reload
    rows = open_import_file(create_import_temp_file)

    field = rows.first
    if [field['username']].reject{|field| field.to_s.strip == ""}.empty?
      raise "username column is not found"
    end

    rows.each do |row|
      username = row['username'].to_s.strip
      user = User.where(:username => username).first
      user.destroy if user
    end
    transition_to!(:completed)
  rescue => e
    self.error_message = "line #{row_num}: #{e.message}"
    transition_to!(:failed)
    raise e
  end

  private
  def self.transition_class
    UserImportFileTransition
  end

  def create_import_temp_file
    tempfile = Tempfile.new(self.class.name.underscore)
    if Setting.uploaded_file.storage == :s3
      uploaded_file_path = user_import.expiring_url(10)
    else
      uploaded_file_path = user_import.path
    end
    open(uploaded_file_path){|f|
      f.each{|line|
        tempfile.puts(convert_encoding(line))
      }
    }
    tempfile.close
    tempfile
  end

  def open_import_file(tempfile)
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

# == Schema Information
#
# Table name: user_import_files
#
#  id                       :integer          not null, primary key
#  user_id                  :integer
#  note                     :text
#  executed_at              :datetime
#  state                    :string(255)
#  user_import_file_name    :string(255)
#  user_import_content_type :string(255)
#  user_import_file_size    :string(255)
#  user_import_updated_at   :datetime
#  user_import_fingerprint  :string(255)
#  edit_mode                :string(255)
#  error_message            :text
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  user_encoding            :string(255)
#
