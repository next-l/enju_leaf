module EnjuLeaf
  module EnjuUser
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def enju_leaf_user_model
        include InstanceMethods

        # Setup accessible (or protected) attributes for your model
        attr_accessible :email, :password, :password_confirmation, :current_password,
          :remember_me, :email_confirmation, :library_id, :locale,
          :keyword_list, :auto_generated_password
        attr_accessible :email, :password, :password_confirmation, :username,
          :current_password, :user_number, :remember_me,
          :email_confirmation, :note, :user_group_id, :library_id, :locale,
          :expired_at, :locked, :required_role_id, :role_id,
          :keyword_list, :user_has_role_attributes, :auto_generated_password,
          :as => :admin

        scope :administrators, where('roles.name = ?', 'Administrator').includes(:role)
        scope :librarians, where('roles.name = ? OR roles.name = ?', 'Administrator', 'Librarian').includes(:role)
        scope :suspended, where('locked_at IS NOT NULL')
        #has_one :agent, :dependent => :destroy
        if defined?(EnjuBiblio)
          has_many :import_requests
          has_many :picture_files, :as => :picture_attachable, :dependent => :destroy
        end
        has_one :user_has_role, :dependent => :destroy
        has_one :role, :through => :user_has_role
        belongs_to :library, :validate => true
        belongs_to :user_group
        belongs_to :required_role, :class_name => 'Role', :foreign_key => 'required_role_id' #, :validate => true
        has_many :export_files if defined?(EnjuExport)
        #has_one :agent_import_result
        accepts_nested_attributes_for :user_has_role

        validates :username, :presence => true, :uniqueness => true, :format => {:with => /\A[0-9A-Za-z][0-9A-Za-z_\-]*[0-9A-Za-z]\Z/}, :allow_blank => true
        validates_uniqueness_of :email, :allow_blank => true
        validates :email, :format => Devise::email_regexp, :allow_blank => true
        validates_date :expired_at, :allow_blank => true

        with_options :if => :password_required? do |v|
          v.validates_presence_of     :password
          v.validates_confirmation_of :password
          v.validates_length_of       :password, :allow_blank => true,
            :within => Devise::password_length
        end

        validates_presence_of     :email, :email_confirmation, :on => :create, :if => proc{|user| !user.operator.try(:has_role?, 'Librarian')}
        validates_associated :user_group, :library #, :agent
        validates_presence_of :user_group, :library, :locale #, :user_number
        validates :user_number, :uniqueness => true, :format => {:with => /\A[0-9A-Za-z_]+\Z/}, :allow_blank => true
        validates_confirmation_of :email, :on => :create, :if => proc{|user| !user.operator.try(:has_role?, 'Librarian')}

        before_validation :set_role_and_agent, :on => :create
        before_validation :set_lock_information
        before_destroy :check_role_before_destroy
        before_save :check_expiration
        before_create :set_expired_at
        after_destroy :remove_from_index
        after_create :set_confirmation

        extend FriendlyId
        friendly_id :username
        #has_paper_trail
        normalize_attributes :username, :user_number
        normalize_attributes :email, :with => :strip

        searchable do
          text :username, :email, :note, :user_number
          text :name do
            #agent.name if agent
          end
          string :username
          string :email
          string :user_number
          integer :required_role_id
          time :created_at
          time :updated_at
          boolean :active do
            active_for_authentication?
          end
          time :confirmed_at
        end

        attr_accessor :first_name, :middle_name, :last_name, :full_name,
          :first_name_transcription, :middle_name_transcription,
          :last_name_transcription, :full_name_transcription,
          :zip_code, :address, :telephone_number, :fax_number, :address_note,
          :operator, :password_not_verified,
          :update_own_account, :auto_generated_password,
          :locked, :current_password #, :agent_id

        paginates_per 10

        def lock_expired_users
          User.find_each do |user|
            user.lock_access! if user.expired? and user.active_for_authentication?
          end
        end

        def export(options = {format: :tsv})
          header = %w(
            username
            email
            user_number
            user_group
            library
            locale
            created_at
            updated_at
            expired_at
            keyword_list
            save_checkout_history
            note
          ).join("\t")
          users = User.all.map{|u|
            lines = []
            lines << u.username
            lines << u.email
            lines << u.user_number
            lines << u.user_group.name
            lines << u.library.name
            lines << u.locale
            lines << u.user_group.created_at
            lines << u.user_group.updated_at
            lines << u.user_group.expired_at
            lines << u.keyword_list.try(:split).try(:join, "//")
            if defined?(EnjuCirculation)
              lines << u.try(:save_checkout_history)
            else
              lines << nil
            end
            lines << u.note
          }
          if options[:format] == :tsv
            users.map{|u| u.join("\t")}.unshift(header).join("\r\n")
          else
            users
          end
        end
      end
    end

    module InstanceMethods
      def password_required?
        !persisted? || !password.nil? || !password_confirmation.nil?
      end

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

      def set_role_and_agent
        self.required_role = Role.where(:name => 'Librarian').first
        self.locale = I18n.default_locale.to_s unless locale
        #unless self.agent
        #  self.agent = Agent.create(:full_name => self.username) if self.username
        #end
      end

      def set_lock_information
        if locked == '1' and self.active_for_authentication?
          lock_access!
        elsif locked == '0' and !self.active_for_authentication?
          unlock_access!
        end
      end

      def set_confirmation
        if operator and respond_to?(:confirm!)
          reload
          confirm!
        end
      end

      def check_expiration
        return if self.has_role?('Administrator')
        if expired_at
          if expired_at.beginning_of_day < Time.zone.now.beginning_of_day
            lock_access! if active_for_authentication?
          end
        end
      end

      def check_role_before_destroy
        if self.has_role?('Administrator')
          raise 'This is the last administrator in this system.' if Role.where(:name => 'Administrator').first.users.size == 1
        end
      end

      def set_auto_generated_password
        password = Devise.friendly_token[0..7]
        self.password = password
        self.password_confirmation = password
      end

      def expired?
        if expired_at
          true if expired_at.beginning_of_day < Time.zone.now.beginning_of_day
        end
      end

      def is_admin?
        true if self.has_role?('Administrator')
      end

      def last_librarian?
        if self.has_role?('Librarian')
          role = Role.where(:name => 'Librarian').first
          true if role.users.size == 1
        end
      end

      def send_confirmation_instructions
        unless self.operator
          Devise::Mailer.confirmation_instructions(self).deliver if self.email.present?
        end
      end

      def set_expired_at
        if expired_at.blank?
          if user_group.valid_period_for_new_user > 0
            self.expired_at = user_group.valid_period_for_new_user.days.from_now.end_of_day
          end
        end
      end

      def deletable_by(current_user)
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
          if Role.where(:name => 'Administrator').first.users.size == 1
            errors[:base] << I18n.t('user.last_administrator')
          end
        end

        if errors[:base] == []
          true
        else
          false
        end
      end

      def patron
        LocalPatron.new({:username => username})
      end

      def full_name
        username
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

