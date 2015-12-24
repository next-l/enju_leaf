module EnjuLeaf
  module EnjuUser
    extend ActiveSupport::Concern

    included do
      scope :administrators, -> { joins(:role).where('roles.name = ?', 'Administrator') }
      scope :librarians, -> { joins(:role).where('roles.name = ? OR roles.name = ?', 'Administrator', 'Librarian') }
      scope :suspended, -> { where('locked_at IS NOT NULL') }
      has_one :profile
      if defined?(EnjuBiblio)
        has_many :import_requests
        has_many :picture_files, as: :picture_attachable, dependent: :destroy
      end
      has_one :user_has_role, dependent: :destroy
      has_one :role, through: :user_has_role
      belongs_to :user_group
      belongs_to :library
      belongs_to :required_role, class_name: 'Role', foreign_key: 'required_role_id'
      accepts_nested_attributes_for :user_has_role

      validates :username, presence: true, uniqueness: true, format: {
        with: /\A[0-9A-Za-z][0-9A-Za-z_\-]*[0-9A-Za-z]\z/
      }
      validates :email, format: Devise::email_regexp, allow_blank: true, uniqueness: true
      validates_date :expired_at, allow_blank: true

      with_options if: :password_required? do |v|
        v.validates_presence_of     :password
        v.validates_confirmation_of :password
        v.validates_length_of       :password, allow_blank: true,
          within: Devise::password_length
      end

      before_validation :set_lock_information
      before_destroy :check_role_before_destroy
      before_save :check_expiration
      after_create :set_confirmation

      extend FriendlyId
      friendly_id :username
      strip_attributes only: :username
      strip_attributes only: :email, allow_empty: true

      attr_accessor :password_not_verified,
        :update_own_account, :auto_generated_password,
        :locked, :current_password #, :agent_id

      paginates_per 10

      def send_devise_notification(notification, *args)
        devise_mailer.send(notification, self, *args).deliver_later
      end

      # 有効期限切れのユーザを一括で使用不可にします。
      def self.lock_expired_users
        User.find_each do |user|
          user.lock_access! if user.expired? and user.active_for_authentication?
        end
      end

      # ユーザの情報をエクスポートします。
      # @param [Hash] options
      def self.export(options = {format: :txt})
        header = %w(
          username
          full_name
          full_name_transcription
          email
          user_number
          role
          user_group
          library
          locale
          locked
          required_role
          created_at
          updated_at
          expired_at
          keyword_list
          note
        )
        header += %w(
          checkout_icalendar_token
          save_checkout_history
        ) if defined? EnjuCirculation
        header << "save_search_history" if defined? EnjuSearchLog
        header << "share_bookmarks" if defined? EnjuBookmark
        users = User.find_each.map{|u|
          lines = []
          lines << u.username
          lines << u.try(:profile).try(:full_name)
          lines << u.try(:profile).try(:full_name_transcription)
          lines << u.email
          lines << u.try(:profile).try(:user_number)
          lines << u.role.name
          lines << u.try(:profile).try(:user_group).try(:name)
          lines << u.try(:profile).try(:library).try(:name)
          lines << u.try(:profile).try(:locale)
          lines << u.access_locked?
          lines << u.try(:profile).try(:required_role).try(:name)
          lines << u.created_at
          lines << u.updated_at
          lines << u.try(:profile).try(:expired_at)
          lines << u.try(:profile).try(:keyword_list).try(:split).try(:join, "//")
          lines << u.try(:profile).try(:note)
          if defined? EnjuCirculation
            lines << u.try(:profile).try(:checkout_icalendar_token)
            lines << u.try(:profile).try(:save_checkout_history)
          end
          if defined? EnjuSearchLog
            lines << u.try(:profile).try(:save_search_history)
          end
          if defined? EnjuBookmark
            lines << u.try(:profile).try(:share_bookmarks)
          end
          lines
        }
        if options[:format] == :txt
          users.map{|u| u.to_csv(col_sep: "\t")}.unshift(header.to_csv(col_sep: "\t")).join
        else
          users
        end
      end
    end

    # ユーザにパスワードが必要かどうかをチェックします。
    # @return [Boolean]
    def password_required?
      if Devise.mappings[:user].modules.include?(:database_authenticatable)
        !persisted? || !password.nil? || !password_confirmation.nil?
      end
    end

    # ユーザが特定の権限を持っているかどうかをチェックします。
    # @param [String] role_in_question 権限名
    # @return [Boolean]
    def has_role?(role_in_question)
      return false unless role
      return true if role.name == role_in_question
      case role.name
      when 'Administrator'
        return true
      when 'Librarian'
        return true if role_in_question == 'User'
      else
        false
      end
    end

    # ユーザに使用不可の設定を反映させます。
    def set_lock_information
      if locked == '1' and self.active_for_authentication?
        lock_access!
      elsif locked == '0' and !self.active_for_authentication?
        unlock_access!
      end
    end

    def set_confirmation
      if respond_to?(:confirm!)
        reload
        confirm!
      end
    end

    # ユーザが有効期限切れかどうかをチェックし、期限切れであれば使用不可に設定します。
    # @return [Object]
    def check_expiration
      return if has_role?('Administrator')
      if expired_at
        if expired_at.beginning_of_day < Time.zone.now.beginning_of_day
          lock_access! if active_for_authentication?
        end
      end
    end

    # ユーザの削除前に、管理者ユーザが不在にならないかどうかをチェックします。
    # @return [Object]
    def check_role_before_destroy
      if has_role?('Administrator')
        if Role.where(name: 'Administrator').first.users.count == 1
          raise username + 'This is the last administrator in this system.'
        end
      end
    end

    # ユーザに自動生成されたパスワードを設定します。
    # @return [String]
    def set_auto_generated_password
      password = Devise.friendly_token[0..7]
      self.password = password
      self.password_confirmation = password
    end

    # ユーザが有効期限切れかどうかをチェックします。
    # @return [Boolean]
    def expired?
      if expired_at
        true if expired_at.beginning_of_day < Time.zone.now.beginning_of_day
      end
    end

    # ユーザが管理者かどうかをチェックします。
    # @return [Boolean]
    def is_admin?
      return true if has_role?('Administrator')
      false
    end

    # ユーザがシステム上の最後のLibrarian権限ユーザかどうかをチェックします。
    # @return [Boolean]
    def last_librarian?
      if has_role?('Librarian')
        role = Role.where(name: 'Librarian').first
        return true if role.users.count == 1
        false
      end
    end

    def send_confirmation_instructions
      Devise::Mailer.confirmation_instructions(self).deliver if email.present?
    end

    # ユーザが削除可能かどうかをチェックします。
    # @param [User] current_user ユーザ
    # @return [Object]
    def deletable_by?(current_user)
      return nil unless current_user
      if defined?(EnjuCirculation)
        # 未返却の資料のあるユーザを削除しようとした
        if checkouts.count > 0
          errors[:base] << I18n.t('user.this_user_has_checked_out_item')
        end
      end

      if has_role?('Librarian')
        # 管理者以外のユーザが図書館員を削除しようとした。図書館員の削除は管理者しかできない
        unless current_user.has_role?('Administrator')
          errors[:base] << I18n.t('user.only_administrator_can_destroy')
        end
        # 最後の図書館員を削除しようとした
        if last_librarian?
          errors[:base] << I18n.t('user.last_librarian')
        end
      end

      # 最後の管理者を削除しようとした
      if has_role?('Administrator')
        if Role.where(name: 'Administrator').first.users.count == 1
          errors[:base] << I18n.t('user.last_administrator')
        end
      end

      if errors[:base] == []
        true
      else
        false
      end
    end
  end
end


# == Schema Information
#
# Table name: users
#
#  id                       :integer         not null, primary key
#  email                    :string(255)     default(""), not null
#  encrypted_password       :string(255)     default(""), not null
#  reset_password_token     :string(255)
#  reset_password_sent_at   :datetime
#  remember_created_at      :datetime
#  sign_in_count            :integer         default(0)
#  current_sign_in_at       :datetime
#  last_sign_in_at          :datetime
#  current_sign_in_ip       :string(255)
#  last_sign_in_ip          :string(255)
#  password_salt            :string(255)
#  confirmation_token       :string(255)
#  confirmed_at             :datetime
#  confirmation_sent_at     :datetime
#  unconfirmed_email        :string(255)
#  failed_attempts          :integer         default(0)
#  unlock_token             :string(255)
#  locked_at                :datetime
#  authentication_token     :string(255)
#  created_at               :datetime        not null
#  updated_at               :datetime        not null
#  deleted_at               :datetime
#  username                 :string(255)     not null
#  library_id               :integer         default(1), not null
#  user_group_id            :integer         default(1), not null
#  expired_at               :datetime
#  required_role_id         :integer         default(1), not null
#  note                     :text
#  keyword_list             :text
#  user_number              :string(255)
#  state                    :string(255)
#  locale                   :string(255)
#  enju_access_key          :string(255)
#  save_checkout_history    :boolean
#  checkout_icalendar_token :string(255)
#  share_bookmarks          :boolean
#  save_search_history      :boolean
#  answer_feed_token        :string(255)
#

