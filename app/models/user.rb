class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :lockable and :timeoutable
  devise :database_authenticatable, #:registerable, :confirmable,
         :recoverable, :rememberable, :trackable, #:validatable,
         :lockable, :lock_strategy => :none, :unlock_strategy => :none

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :username, :current_password, :user_number, :remember_me

  scope :administrators, :include => ['role'], :conditions => ['roles.name = ?', 'Administrator']
  scope :librarians, :include => ['role'], :conditions => ['roles.name = ? OR roles.name = ?', 'Administrator', 'Librarian']
  scope :suspended, :conditions => ['locked_at IS NOT NULL']
  has_one :patron
  has_many :checkouts
  has_many :import_requests
  has_many :sent_messages, :foreign_key => 'sender_id', :class_name => 'Message'
  has_many :received_messages, :foreign_key => 'receiver_id', :class_name => 'Message'
  #has_many :user_has_shelves
  #has_many :shelves, :through => :user_has_shelves
  has_many :picture_files, :as => :picture_attachable, :dependent => :destroy
  has_many :import_requests
  has_one :user_has_role
  has_one :role, :through => :user_has_role
  has_many :bookmarks, :dependent => :destroy
  has_many :reserves, :dependent => :destroy
  has_many :reserved_manifestations, :through => :reserves, :source => :manifestation
  has_many :questions
  has_many :answers
  has_many :search_histories, :dependent => :destroy
  has_many :baskets, :dependent => :destroy
  has_many :purchase_requests
  has_many :order_lists
  has_many :subscriptions
  has_many :checkout_stat_has_users
  has_many :user_checkout_stats, :through => :checkout_stat_has_users
  has_many :reserve_stat_has_users
  has_many :user_reserve_stats, :through => :reserve_stat_has_users
  belongs_to :library, :validate => true
  belongs_to :user_group
  belongs_to :required_role, :class_name => 'Role', :foreign_key => 'required_role_id' #, :validate => true
  has_one :patron_import_result

  validates_presence_of :username
  validates_uniqueness_of :username
  validates_uniqueness_of :email, :scope => authentication_keys[1..-1], :case_sensitive => false, :allow_blank => true
  EMAIL_REGEX = /^([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})$/i
  validates_format_of     :email, :with  => EMAIL_REGEX, :allow_blank => true

  with_options :if => :password_required? do |v|
    v.validates_presence_of     :password
    v.validates_confirmation_of :password
    v.validates_length_of       :password, :within => 6..20, :allow_blank => true
  end

  validates_presence_of     :email, :email_confirmation, :on => :create, :if => proc{|user| !user.operator.try(:has_role?, 'Librarian')}
  validates_associated :patron, :user_group, :library
  validates_presence_of :user_group, :library, :locale #, :user_number
  validates_uniqueness_of :user_number, :with=>/\A[0-9A-Za-z_]+\Z/, :allow_blank => true
  validates_confirmation_of :email, :email_confirmation, :on => :create, :if => proc{|user| !user.operator.try(:has_role?, 'Librarian')}
  before_validation :set_role_and_patron, :on => :create
  before_validation :set_lock_information
  before_destroy :check_item_before_destroy, :check_role_before_destroy
  before_save :check_expiration
  before_create :set_expired_at
  after_destroy :remove_from_index
  after_create :set_confirmation
  after_save :index_patron
  after_destroy :index_patron

  has_friendly_id :username
  #acts_as_tagger
  has_paper_trail
  normalize_attributes :username, :user_number #, :email

  searchable do
    text :username, :email, :note, :user_number
    text :name do
      patron.name if patron
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
    :role_id, :patron_id, :operator, :password_not_verified,
    :update_own_account, :auto_generated_password, :current_password,
    :locked

  def self.per_page
    10
  end
 
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
    self.required_role = Role.find_by_name('Librarian')
    self.locale = I18n.default_locale.to_s
    unless self.patron
      self.patron = Patron.create(:full_name => self.username) if self.username
    end
  end

  def set_lock_information
    if self.locked == '1' and self.active_for_authentication?
      lock_access!
    elsif self.locked == '0' and !self.active_for_authentication?
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
        lock_access! if self.active_for_authentication?
      end
    end
  end

  def check_item_before_destroy
    # TODO: 貸出記録を残す場合
    if checkouts.size > 0
      raise 'This user has items still checked out.'
    end
  end

  def check_role_before_destroy
    if self.has_role?('Administrator')
      raise 'This is the last administrator in this system.' if Role.find_by_name('Administrator').users.size == 1
    end
  end

  def set_auto_generated_password
    password = Devise.friendly_token[0..7]
    self.reset_password!(password, password)
  end

  def reset_checkout_icalendar_token
    self.checkout_icalendar_token = Devise.friendly_token
  end

  def delete_checkout_icalendar_token
    self.checkout_icalendar_token = nil
  end

  def reset_answer_feed_token
    self.answer_feed_token = Devise.friendly_token
  end

  def delete_answer_feed_token
    self.answer_feed_token = nil
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

  def checked_item_count
    checkout_count = {}
    CheckoutType.all.each do |checkout_type|
      # 資料種別ごとの貸出中の冊数を計算
      checkout_count[:"#{checkout_type.name}"] = self.checkouts.count_by_sql(["
        SELECT count(item_id) FROM checkouts
          WHERE item_id IN (
            SELECT id FROM items
              WHERE checkout_type_id = ?
          )
          AND user_id = ? AND checkin_id IS NULL", checkout_type.id, self.id]
      )
    end
    return checkout_count
  end

  def reached_reservation_limit?(manifestation)
    return true if self.user_group.user_group_has_checkout_types.available_for_carrier_type(manifestation.carrier_type).where(:user_group_id => self.user_group.id).collect(&:reservation_limit).max <= self.reserves.waiting.size
    false
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

  def send_message(status, options = {})
    MessageRequest.transaction do
      request = MessageRequest.new
      request.sender = User.find('admin')
      request.receiver = self
      request.message_template = MessageTemplate.localized_template(status, self.locale)
      request.save_message_body(options)
      request.sm_send_message!
    end
  end

  def owned_tags_by_solr
    bookmark_ids = bookmarks.collect(&:id)
    if bookmark_ids.empty?
      []
    else
      Tag.bookmarked(bookmark_ids)
    end
  end

  def check_update_own_account(user)
    if user == self
      self.update_own_account = true
      return true
    end
    false
  end

  def send_confirmation_instructions
    unless self.operator
      Devise::Mailer.delay.confirmation_instructions(self) if self.email.present?
    end
  end

  def set_expired_at
    if self.user_group.valid_period_for_new_user > 0
      self.expired_at = self.user_group.valid_period_for_new_user.days.from_now.end_of_day
    end
  end

  def deletable_by(current_user)
    # 未返却の資料のあるユーザを削除しようとした
    if self.checkouts.count > 0
      errors[:base] << I18n.t('user.this_user_has_checked_out_item')
    end

    if self.has_role?('Librarian')
      # 管理者以外のユーザが図書館員を削除しようとした。図書館員の削除は管理者しかできない
      unless current_user.has_role?('Administrator')
        errors[:base] << I18n.t('user.only_administrator_can_destroy')
      end
      # 最後の図書館員を削除しようとした
      if self.last_librarian?
        errors[:base] << I18n.t('user.last_librarian')
      end
    end

    # 最後の管理者を削除しようとした
    if self.has_role?('Administrator')
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
end
