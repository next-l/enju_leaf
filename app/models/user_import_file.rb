class UserImportFile < ActiveRecord::Base
  include Statesman::Adapters::ActiveRecordQueries
  include ImportFile
  default_scope {order('user_import_files.id DESC')}
  scope :not_imported, -> { in_state(:pending) }
  scope :stucked, -> { in_state(:pending).where('user_import_files.created_at < ?', 1.hour.ago) }

  if Setting.uploaded_file.storage == :s3
    has_attached_file :user_import, storage: :s3,
      s3_credentials: "#{Setting.amazon}",
      s3_permissions: :private
  else
    has_attached_file :user_import,
      path: ":rails_root/private/system/:class/:attachment/:id_partition/:style/:filename"
  end
  validates_attachment_content_type :user_import, content_type: [
    'text/csv',
    'text/plain',
    'text/tab-separated-values',
    'application/octet-stream',
    'application/vnd.ms-excel'
  ]
  validates_attachment_presence :user_import
  belongs_to :user, validate: true
  belongs_to :default_user_group, class_name: 'UserGroup'
  belongs_to :default_library, class_name: 'Library'
  has_many :user_import_results

  has_many :user_import_file_transitions

  enju_import_file_model
  attr_accessor :mode

  def state_machine
    UserImportFileStateMachine.new(self, transition_class: UserImportFileTransition)
  end

  delegate :can_transition_to?, :transition_to!, :transition_to, :current_state,
    to: :state_machine

  def import
    transition_to!(:started)
    num = { user_imported: 0, user_found: 0, failed: 0 }
    rows = open_import_file(create_import_temp_file(user_import))
    row_num = 1

    field = rows.first
    if [field['username']].reject{ |f| f.to_s.strip == "" }.empty?
      raise "username column is not found"
    end

    rows.each do |row|
      row_num += 1
      next if row['dummy'].to_s.strip.present?
      import_result = UserImportResult.create!(
        user_import_file_id: id, body: row.fields.join("\t")
      )

      username = row['username']
      new_user = User.where(username: username).first
      if new_user
        import_result.user = new_user
        import_result.save
        num[:user_found] += 1
      else
        new_user = User.new
        new_user.role = Role.where(name: row['role']).first
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
        new_user.assign_attributes(set_user_params(new_user, row))
        profile = Profile.new
        profile.assign_attributes(set_profile_params(row))

        if new_user.save
          if profile.locked
            new_user.lock_access!
          end
          new_user.profile = profile
          if profile.save
            num[:user_imported] += 1
            import_result.user = new_user
            import_result.save!
          else
            num[:failed] += 1
          end
        else
          num[:failed] += 1
        end
      end
    end

    Sunspot.commit
    rows.close
    transition_to!(:completed)
    send_message
    num
  rescue => e
    self.error_message = "line #{row_num}: #{e.message}"
    save
    transition_to!(:failed)
    raise e
  end

  def modify
    transition_to!(:started)
    num = { user_updated: 0, user_not_found: 0, failed: 0 }
    rows = open_import_file(create_import_temp_file(user_import))
    row_num = 1

    field = rows.first
    if [field['username']].reject{|f| f.to_s.strip == ""}.empty?
      raise "username column is not found"
    end

    rows.each do |row|
      row_num += 1
      next if row['dummy'].to_s.strip.present?
      import_result = UserImportResult.create!(
        user_import_file_id: id, body: row.fields.join("\t")
      )

      username = row['username']
      new_user = User.where(username: username).first
      if new_user
        new_user.assign_attributes(set_user_params(new_user, row), as: :admin)
        if new_user.save
          num[:user_updated] += 1
          import_result.user = new_user
          import_result.save!
        else
          num[:failed] += 1
        end
      else
        num[:user_not_found] += 1
      end
    end

    rows.close
    transition_to!(:completed)
    Sunspot.commit
    num
  rescue => e
    self.error_message = "line #{row_num}: #{e.message}"
    save
    transition_to!(:failed)
    raise e
  end

  def remove
    transition_to!(:started)
    row_num = 1
    rows = open_import_file(create_import_temp_file(user_import))

    field = rows.first
    if [field['username']].reject{ |f| f.to_s.strip == "" }.empty?
      raise "username column is not found"
    end

    rows.each do |row|
      row_num += 1
      username = row['username'].to_s.strip
      user = User.where(username: username).first
      user.destroy if user
    end
    transition_to!(:completed)
  rescue => e
    self.error_message = "line #{row_num}: #{e.message}"
    save
    transition_to!(:failed)
    raise e
  end

  private
  def self.transition_class
    UserImportFileTransition
  end

  def self.initial_state
    :pending
  end

  def open_import_file(tempfile)
    file = CSV.open(tempfile.path, 'r:utf-8', col_sep: "\t")
    header_columns = %w(
      username role email password user_group user_number expired_at
      full_name full_name_transcription required_role locked
      keyword_list note locale library dummy
    )
    if defined?(EnjuCirculation)
      header_columns += %w(checkout_icalendar_token save_checkout_history)
    end
    if defined?(EnjuSearchLog)
      header_columns += %w(save_search_history)
    end
    if defined?(EnjuBookmark)
      header_columns += %w(share_bookmarks)
    end

    header = file.first
    ignored_columns = header - header_columns
    unless ignored_columns.empty?
      self.error_message = I18n.t('import.following_column_were_ignored', column: ignored_columns.join(', '))
      save!
    end
    rows = CSV.open(tempfile.path, 'r:utf-8', headers: header, col_sep: "\t")
    UserImportResult.create!(user_import_file_id: id, body: header.join("\t"))
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

  private
  def set_user_params(_new_user, row)
    params = {}
    params[:email] = row['email'] if row['email'].present?

    if row['password'].present?
      params[:password] = row['password']
    else
      params[:password] = Devise.friendly_token[0..7]
    end
    params
  end

  def set_profile_params(row)
    params = {}
    user_group = UserGroup.where(name: row['user_group']).first
    unless user_group
      user_group = default_user_group
    end
    params[:user_group_id] = user_group.id if user_group

    required_role = Role.where(name: row['required_role']).first
    unless required_role
      required_role = Role.where(name: 'Librarian').first
    end
    params[:required_role_id] = required_role.id if required_role

    params[:user_number] = row['user_number']
    params[:full_name] = row['full_name']
    params[:full_name_transcription] = row['full_name_transcription']

    if row['expired_at'].present?
      params[:expired_at] = Time.zone.parse(row['expired_at']).end_of_day
    end

    if row['keyword_list'].present?
      params[:keyword_list] = row['keyword_list'].split('//').join("\n")
    end

    params[:note] = row['note']

    if %w(t true).include?(row['locked'].to_s.downcase.strip)
      params[:locked] = true 
    end

    if I18n.available_locales.include?(row['locale'].to_s.to_sym)
      params[:locale] = row['locale']
    end

    library = Library.where(name: row['library'].to_s.strip).first
    unless library
      library = default_library || Library.web
    end
    params[:library_id] = library.id if library

    if defined?(EnjuCirculation)
      params[:checkout_icalendar_token] = row['checkout_icalendar_token'] if row['checkout_icalendar_token'].present?
      params[:save_checkout_history] = row['save_checkout_history'] if row['save_checkout_history'].present?
    end
    if defined?(EnjuSearchLog)
      params[:save_search_history] = row['save_search_history'] if row['save_search_history'].present?
    end
    if defined?(EnjuBookmark)
      params[:share_bookmarks] = row['share_bookmarks'] if row['share_bookmarks'].present?
    end
    params
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
#  default_library_id       :integer
#  default_user_group_id    :integer
#
