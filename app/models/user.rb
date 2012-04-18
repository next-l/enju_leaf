class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :lockable and :timeoutable
  devise :database_authenticatable, #:registerable, :confirmable,
         :recoverable, :rememberable, :trackable, #:validatable,
         :lockable, :lock_strategy => :none, :unlock_strategy => :none

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :username, :current_password, :user_number, :remember_me,
    :email_confirmation, :note, :user_group_id, :library_id, :locale, :expired_at, :locked, :required_role_id, :role_id,
    :keyword_list #, :as => :admin

  scope :administrators, where('roles.name = ?', 'Administrator').includes(:role)
  scope :librarians, where('roles.name = ? OR roles.name = ?', 'Administrator', 'Librarian').includes(:role)
  scope :suspended, where('locked_at IS NOT NULL')
  #has_one :patron
  has_many :import_requests
  has_many :picture_files, :as => :picture_attachable, :dependent => :destroy
  has_many :import_requests
  has_one :user_has_role
  has_one :role, :through => :user_has_role
  has_many :subscriptions
  belongs_to :library, :validate => true
  belongs_to :user_group
  belongs_to :required_role, :class_name => 'Role', :foreign_key => 'required_role_id' #, :validate => true
  #has_one :patron_import_result

  validates :username, :presence => true, :uniqueness => true
  validates_uniqueness_of :email, :scope => authentication_keys[1..-1], :case_sensitive => false, :allow_blank => true
  validates :email, :format => {:with => /\A([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})\z/i}, :allow_blank => true
  validates_date :expired_at, :allow_blank => true

  with_options :if => :password_required? do |v|
    v.validates_presence_of     :password
    v.validates_confirmation_of :password
    v.validates_length_of       :password, :within => 6..20, :allow_blank => true
  end

  validates_presence_of     :email, :email_confirmation, :on => :create, :if => proc{|user| !user.operator.try(:has_role?, 'Librarian')}
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
  #acts_as_tagger
  has_paper_trail
  normalize_attributes :username, :user_number #, :email

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
    :role_id, :operator, :password_not_verified,
    :update_own_account, :auto_generated_password,
    :locked, :current_password #, :patron_id

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
    self.required_role = Role.where(:name => 'Librarian').first
    self.locale = I18n.default_locale.to_s
    #unless self.patron
    #  self.patron = Patron.create(:full_name => self.username) if self.username
    #end
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

  def check_role_before_destroy
    if self.has_role?('Administrator')
      raise 'This is the last administrator in this system.' if Role.where(:name => 'Administrator').first.users.size == 1
    end
  end

  def set_auto_generated_password
    password = Devise.friendly_token[0..7]
    self.reset_password!(password, password)
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
      Devise::Mailer.delay.confirmation_instructions(self) if self.email.present?
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

  def self.create_with_params(params, current_user)
    user = User.new
    user.operator = current_user
    #self.username = params[:user][:login]
    user.note = params[:note]
    #user.user_group_id = params[:user_group_id] ||= 1
    user.assign_attributes(params)
    #user_group_id = params[:user_group_id] ||= 1
    user.library_id = params[:library_id] ||= 1
    user.role_id = params[:role_id] ||= 1
    user.required_role_id = params[:required_role_id] ||= 1
    user.keyword_list = params[:keyword_list]
    user.user_number = params[:user_number]
    user.locale = params[:locale]
    if defined?(EnjuCirculation)
      user.save_checkout_history = params[:save_checkout_history] ||= false
    end
    if defined?(EnjuSearchLog)
      user.save_search_history = params[:save_search_history] ||= false
    end
    #if user.patron_id
    #  user.patron = Patron.find(user.patron_id) rescue nil
    #end
    user
  end

  def update_with_params(params, current_user)
    self.operator = current_user
    #self.username = params[:login]
    self.keyword_list = params[:keyword_list]
    self.email = params[:email] if params[:email]
    #self.note = params[:note]
    if defined?(EnjuCirculation)
      self.checkout_icalendar_token = params[:checkout_icalendar_token] ||= nil
      self.save_checkout_history = params[:save_checkout_history] ||= false
    end
    if defined?(EnjuSearchLog)
      self.save_search_history = params[:save_search_history] ||= false
    end

    if current_user.has_role?('Librarian')
      self.note = params[:note]
      self.user_group_id = params[:user_group_id] || 1
      self.library_id = params[:library_id] || 1
      self.role_id = params[:role_id]
      self.required_role_id = params[:required_role_id] || 1
      self.user_number = params[:user_number]
      self.locale = params[:locale]
      self.locked = params[:locked]
      self.expired_at = params[:expired_at]
    end
    self
  end

  def deletable?
    if defined?(EnjuCirculation)
      true if checkouts.not_returned.empty? and id != 1
    else
      true if id != 1
    end
  end

  def patron
    LocalPatron.new(self)
  end

  if defined?(EnjuCirculation)
    attr_accessible :save_checkout_history, :checkout_icalendar_token

    has_many :checkouts, :dependent => :nullify
    has_many :reserves, :dependent => :destroy
    has_many :reserved_manifestations, :through => :reserves, :source => :manifestation
    has_many :checkout_stat_has_users
    has_many :user_checkout_stats, :through => :checkout_stat_has_users
    has_many :reserve_stat_has_users
    has_many :user_reserve_stats, :through => :reserve_stat_has_users
    has_many :baskets, :dependent => :destroy

    before_destroy :check_item_before_destroy

    def check_item_before_destroy
      # TODO: 貸出記録を残す場合
      if checkouts.size > 0
        raise 'This user has items still checked out.'
      end
    end

    def reset_checkout_icalendar_token
      self.checkout_icalendar_token = Devise.friendly_token
    end

    def delete_checkout_icalendar_token
      self.checkout_icalendar_token = nil
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
      return true if self.user_group.user_group_has_checkout_types.available_for_carrier_type(manifestation.carrier_type).where(:user_group_id => self.user_group.id).collect(&:reservation_limit).max.to_i <= self.reserves.waiting.size
      false
    end
  end

  if defined?(EnjuQuestion)
    has_many :questions
    has_many :answers

    def reset_answer_feed_token
      self.answer_feed_token = Devise.friendly_token
    end

    def delete_answer_feed_token
      self.answer_feed_token = nil
    end
  end

  if defined?(EnjuBookmark)
    has_many :bookmarks, :dependent => :destroy

    def owned_tags_by_solr
      bookmark_ids = bookmarks.collect(&:id)
      if bookmark_ids.empty?
        []
      else
        Tag.bookmarked(bookmark_ids)
      end
    end
  end

  if defined?(EnjuMessage)
    has_many :sent_messages, :foreign_key => 'sender_id', :class_name => 'Message'
    has_many :received_messages, :foreign_key => 'receiver_id', :class_name => 'Message'

    def send_message(status, options = {})
      MessageRequest.transaction do
        request = MessageRequest.new
        request.sender = User.find(1)
        request.receiver = self
        request.message_template = MessageTemplate.localized_template(status, self.locale)
        request.save_message_body(options)
        request.sm_send_message!
      end
    end
  end

  if defined?(EnjuPurchaseRequest)
    has_many :purchase_requests
    has_many :order_lists
  end

  if defined?(EnjuSearchLog)
    attr_accessible :save_search_history

    has_many :search_histories, :dependent => :destroy
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

