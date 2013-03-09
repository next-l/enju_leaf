module EnjuLeaf
  module User
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def enju_user
        include InstanceMethods

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
        #has_one :patron, :dependent => :destroy
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
        #has_one :patron_import_result
        accepts_nested_attributes_for :user_has_role
  
        validates :username, :presence => true, :uniqueness => true, :format => {:with => /\A[0-9A-Za-z][0-9A-Za-z_\-]+[0-9A-Za-z]\Z/}, :allow_blank => true
        validates_uniqueness_of :email, :scope => authentication_keys[1..-1], :case_sensitive => false, :allow_blank => true
        validates :email, :format => {:with => /\A([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})\Z/i}, :allow_blank => true
        validates_date :expired_at, :allow_blank => true
  
        with_options :if => :password_required? do |v|
          v.validates_presence_of         :password
          v.validates_confirmation_of :password
          v.validates_length_of           :password, :within => 6..64, :allow_blank => true
        end
  
        validates_presence_of         :email, :email_confirmation, :on => :create, :if => proc{|user| !user.operator.try(:has_role?, 'Librarian')}
        validates_associated :user_group, :library #, :patron
        validates_presence_of :user_group, :library, :locale #, :user_number
        validates :user_number, :uniqueness => true, :format => {:with => /\A[0-9A-Za-z_]+\Z/}, :allow_blank => true
        validates_confirmation_of :email, :on => :create, :if => proc{|user| !user.operator.try(:has_role?, 'Librarian')}
  
        before_validation :set_role_and_patron, :on => :create
        before_validation :set_lock_information
        before_destroy :check_role_before_destroy
        before_save :check_expiration
        before_create :set_expired_at
        after_destroy :remove_from_index
        after_create :set_confirmation
        #after_save :index_patron
        #after_destroy :index_patron
  
        extend FriendlyId
        friendly_id :username
        has_paper_trail
        normalize_attributes :username, :user_number
  
        searchable do
          text :username, :email, :note, :user_number
          text :name do
                #patron.name if patron
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
          :locked, :current_password #, :patron_id
  
        paginates_per 10
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

      def set_role_and_patron
        self.required_role = Role.where(:name => 'Librarian').first
        self.locale = I18n.default_locale.to_s
        #unless self.patron
        #  self.patron = Patron.create(:full_name => self.username) if self.username
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
  
      def index_patron
        if self.patron
          self.patron.index
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

      def self.lock_expired_users
        User.find_each do |user|
          user.lock_access! if user.expired? and user.active_for_authentication?
        end
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
        if self.user_group.valid_period_for_new_user > 0
          self.expired_at = self.user_group.valid_period_for_new_user.days.from_now.end_of_day
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

      def deletable?
        if defined?(EnjuCirculation)
          true if checkouts.not_returned.empty? and id != 1
        else
          true if id != 1
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
