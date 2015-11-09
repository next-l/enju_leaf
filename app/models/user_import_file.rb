class UserImportFile < ActiveRecord::Base
  include Statesman::Adapters::ActiveRecordQueries
  include ImportFile
  scope :not_imported, -> { in_state(:pending) }
  scope :stucked, -> { in_state(:pending).where('user_import_files.created_at < ?', 1.hour.ago) }

  validates :user_import, presence: true, on: :create
  belongs_to :user, validate: true
  belongs_to :default_user_group, class_name: 'UserGroup'
  belongs_to :default_library, class_name: 'Library'
  has_many :user_import_results

  has_many :user_import_file_transitions

  before_save :set_fingerprint
  attachment :user_import
  enju_import_file_model
  attr_accessor :mode

  def state_machine
    UserImportFileStateMachine.new(self, transition_class: UserImportFileTransition)
  end

  delegate :can_transition_to?, :transition_to!, :transition_to, :current_state,
    to: :state_machine

  # 利用者情報をTSVファイルを用いて作成します。
  def import
    transition_to!(:started)
    num = { user_imported: 0, user_found: 0, failed: 0 }
    rows = open_import_file(create_import_temp_file(user_import.download))
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
        new_user.username = username
        new_user.assign_attributes(set_user_params(row))
        profile = Profile.new
        profile.assign_attributes(set_profile_params(row))

        if new_user.save
          new_user.profile = profile
          if profile.save
            num[:user_imported] += 1
            import_result.user = new_user
            import_result.save!
          else
            num[:failed] += 1
          end
        else
          import_result.error_message = new_user.errors.full_messages.join("\n")
          import_result.save
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

  # 利用者情報をTSVファイルを用いて更新します。
  def modify
    transition_to!(:started)
    num = { user_updated: 0, user_not_found: 0, failed: 0 }
    rows = open_import_file(create_import_temp_file(user_import.download))
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
      if new_user.try(:profile)
        new_user.assign_attributes(set_user_params(row))
        new_user.profile.assign_attributes(set_profile_params(row))
        Profile.transaction do
          if new_user.save and new_user.profile.save
            num[:user_updated] += 1
            import_result.user = new_user
            import_result.save!
          else
            num[:failed] += 1
          end
        end
      else
        num[:user_not_found] += 1
      end
    end

    rows.close
    transition_to!(:completed)
    Sunspot.commit
    send_message
    num
  rescue => e
    self.error_message = "line #{row_num}: #{e.message}"
    save
    transition_to!(:failed)
    raise e
  end

  # 利用者情報をTSVファイルを用いて削除します。
  def remove
    transition_to!(:started)
    row_num = 1
    rows = open_import_file(create_import_temp_file(user_import.download))

    field = rows.first
    if [field['username']].reject{ |f| f.to_s.strip == "" }.empty?
      raise "username column is not found"
    end

    rows.each do |row|
      row_num += 1
      username = row['username'].to_s.strip
      remove_user = User.where(username: username).first
      if remove_user.try(:deletable_by?, user)
        UserImportFile.transaction do
          remove_user.destroy
          remove_user.profile.destroy
        end
      end
    end
    transition_to!(:completed)
    send_message
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

  # インポート作業用のファイルを読み込みます。
  # @param [File] tempfile 作業用のファイル
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

  # 未処理のインポート作業用のファイルを一括で処理します。
  def self.import
    UserImportFile.not_imported.each do |file|
      file.import_start
    end
  rescue
    Rails.logger.info "#{Time.zone.now} importing resources failed!"
  end

  private
  # ユーザ情報のパラメータを設定します。
  # @param [Hash] row 利用者情報のハッシュ
  def set_user_params(row)
    params = {}
    params[:email] = row['email'] if row['email'].present?

    if %w(t true).include?(row['locked'].to_s.downcase.strip)
      params[:locked] = '1'
    end

    if row['password'].present?
      params[:password] = row['password']
    else
      params[:password] = Devise.friendly_token[0..7]
    end

    if %w(t true).include?(row['locked'].to_s.downcase.strip)
      params[:locked] = '1'
    end

    params
  end

  # 利用者情報のパラメータを設定します。
  # @param [Hash] row 利用者情報のハッシュ
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

    params[:user_number] = row['user_number'] if row['user_number']
    params[:full_name] = row['full_name'] if row['full_name']
    params[:full_name_transcription] = row['full_name_transcription'] if row['full_name_transcription']

    if row['expired_at'].present?
      params[:expired_at] = Time.zone.parse(row['expired_at']).end_of_day
    end

    if row['keyword_list'].present?
      params[:keyword_list] = row['keyword_list'].split('//').join("\n")
    end

    params[:note] = row['note'] if row['note']

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

  # TSVファイルのハッシュ値を設定します。
  def set_fingerprint
    self.user_import_fingerprint = Digest::SHA1.file(user_import.download.path).hexdigest
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
#  user_import_file_name    :string
#  user_import_content_type :string
#  user_import_file_size    :integer
#  user_import_updated_at   :datetime
#  user_import_fingerprint  :string
#  edit_mode                :string
#  error_message            :text
#  created_at               :datetime
#  updated_at               :datetime
#  user_encoding            :string
#  default_library_id       :integer
#  default_user_group_id    :integer
#  user_import_id           :string
#  user_import_size         :integer
#
