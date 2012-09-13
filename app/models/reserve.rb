# -*- encoding: utf-8 -*-
class Reserve < ActiveRecord::Base
  self.extend ApplicationHelper
  self.extend ReservesHelper
  scope :hold, where('item_id IS NOT NULL AND state = ?', 'retained')
  scope :not_hold, where(:item_id => nil)
  scope :waiting, where('canceled_at IS NULL AND expired_at > ? AND state != ?', Time.zone.now, 'completed')
  scope :completed, where('checked_out_at IS NOT NULL')
  scope :canceled, where('canceled_at IS NOT NULL')
  scope :retained, where(:state => ['retained'], :retained => false)
  scope :in_process, where(:state => ['in_process'])
  scope :can_change_position, where("state = ? AND position IS NOT NULL", 'requested')
  scope :not_retained, where("position IS NOT NULL")
  scope :not_waiting, where(:state => ['retained'])
  #scope :not_waiting, where(:state => ['retained','canceled','completed'])
  scope :will_expire_retained, lambda {|datetime| {:conditions => ['checked_out_at IS NULL AND canceled_at IS NULL AND expired_at <= ? AND state = ?', datetime, 'retained'], :order => 'expired_at'}}
  scope :will_expire_requested, lambda {|datetime| {:conditions => ['checked_out_at IS NULL AND canceled_at IS NULL AND expired_at <= ? AND state = ?', datetime, 'requested'], :order => 'expired_at'}}
  scope :will_expire_pending, lambda {|datetime| {:conditions => ['checked_out_at IS NULL AND canceled_at IS NULL AND expired_at <= ? AND state = ?', datetime, 'pending'], :order => 'expired_at'}}
  scope :created, lambda {|start_date, end_date| {:conditions => ['created_at >= ? AND created_at < ?', start_date, end_date]}}
  scope :not_sent_expiration_notice_to_patron, where(:state => 'expired', :expiration_notice_to_patron => false)
  scope :not_sent_expiration_notice_to_library, where(:state => 'expired', :expiration_notice_to_library => false)
  scope :sent_expiration_notice_to_patron, where(:state => 'expired', :expiration_notice_to_patron => true)
  scope :sent_expiration_notice_to_library, where(:state => 'expired', :expiration_notice_to_library => true)
  scope :not_sent_cancel_notice_to_patron, where(:state => 'canceled', :expiration_notice_to_patron => false)
  scope :not_sent_cancel_notice_to_library, where(:state => 'canceled', :expiration_notice_to_library => false)
  scope :show_reserves, joins(:manifestation).where(:state => ['requested', 'retained', 'in_process', 'completed', 'expired', 'canceled']) 
  scope :user_show_reserves, joins(:manifestation).where(:state => ['requested', 'retained', 'in_process'])  
  acts_as_list :scope => :manifestation_id

  belongs_to :user, :validate => true
  belongs_to :created_user, :class_name => 'User', :foreign_key => 'created_by', :validate => true
  belongs_to :manifestation, :validate => true
  belongs_to :librarian, :class_name => 'User', :validate => true
  belongs_to :item, :validate => true
  has_one :inter_library_loan
  belongs_to :request_status_type

  validates_associated :user, :librarian, :item, :request_status_type, :manifestation
  validates_presence_of :user, :manifestation, :request_status_type, :expired_at, :created_by
  #validates_uniqueness_of :manifestation_id, :scope => :user_id
  validates_date :expired_at, :allow_blank => true
  validate :manifestation_must_include_item
  validate :available_for_reservation?, :on => :create
  before_validation :set_item_and_manifestation, :on => :create
  before_validation :set_expired_at
  before_validation :set_request_status, :on => :create

  attr_accessor :user_number, :item_identifier

  state_machine :initial => :pending do
    before_transition [:pending, :requested, :retained, :in_process] => :requested, :do => :do_request
    before_transition [:pending, :requested, :retained, :in_process] => :retained, :do => :retain
    before_transition [:pending, :requested, :in_process] => :in_process, :do => :to_process
    before_transition [:pending ,:requested, :retained, :in_process] => :canceled, :do => :cancel
    before_transition [:pending, :requested, :retained, :in_process] => :expired, :do => :expire
    before_transition [:retained, :requested] => :completed, :do => :checkout


    event :sm_request do
      transition [:pending, :requested, :retained, :in_process] => :requested
    end

    event :sm_retain do
      transition [:pending, :requested, :retained, :in_process] => :retained
    end

    event :sm_process do
      transition [:pending, :requested] => :in_process, :do => :to_process
    end

    event :sm_cancel do
      transition [:pending, :requested, :retained, :in_process] => :canceled
    end

    event :sm_expire do
      transition [:pending, :requested, :retained] => :expired
    end

    event :sm_complete do
      transition [:requested, :retained] => :completed
    end
  end

  searchable do
    text :title do
      titles = []
      titles << self.manifestation.original_title if self.manifestation
      titles << self.manifestation.title_transcription if self.manifestation
    end
    text :creator do
      self.manifestation.creator if self.manifestation
    end
    text :publisher do
      self.manifestation.publisher if self.manifestation
    end
    text :contributor do
      self.manifestation.contributor if self.manifestation
    end
    text :username do
      self.user.username if self.user
    end
    text :email do
      self.user.email if self.user
    end
    text :full_name do
      full_name = []
      full_name << self.user.patron.full_name if self.user.patron 
      full_name << self.user.patron.full_name_transcription if self.user.patron
    end
    text :telephone_number do
      telephone_numbers = []
      telephone_numbers << self.user.patron.telephone_number_1.gsub("-", "") if self.user.patron && self.user.patron.telephone_number_1
      telephone_numbers << self.user.patron.telephone_number_2.gsub("-", "") if self.user.patron && self.user.patron.telephone_number_2
      telephone_numbers << self.user.patron.extelephone_number_1.gsub("-", "") if self.user.patron && self.user.patron.extelephone_number_1
      telephone_numbers << self.user.patron.extelephone_number_2.gsub("-", "") if self.user.patron && self.user.patron.extelephone_number_2
      telephone_numbers << self.user.patron.fax_number_1.gsub("-", "") if self.user.patron && self.user.patron.fax_number_1
      telephone_numbers << self.user.patron.fax_number_2.gsub("-", "") if self.user.patron && self.user.patron.fax_number_2
    end
    text :address do
      addresses = []
      addresses << self.user.patron.address_1 if self.user.patron
      addresses << self.user.patron.address_2 if self.user.patron
    end
    time :date_of_birth do
      self.user.patron.date_of_birth if self.user.patron
    end
    string :state
    integer :user_id
    integer :manifestation_id
    integer :item_id
    integer :request_status_type_id
    integer :receipt_library_id
    integer :information_type_id
    boolean :retained
    time :created_at
    time :updated_at
    time :expired_at
  end

  paginates_per 10

  def reserved_library
    #@reserve.user.library
    role_id = self.created_user.role.id rescue nil
    if role_id.nil?
      return User.administrators.first.library.display_name
    end
    if Role.librarian_role_ids.include?(role_id)
      return self.created_user.library
    end
    return nil
  end

  def reserved_library_name
    #@reserve.user.library.display_name rescue ""
    return reserved_library.display_name rescue "WebOPAC" 
  end

  def set_item_and_manifestation
    item = Item.where(:item_identifier => item_identifier).first
    manifestation = item.manifestation if item
  end

  def set_request_status
    self.request_status_type = RequestStatusType.where(:name => 'In Process').first
  end

  def set_expired_at
    if self.user and self.manifestation
      if self.canceled_at.blank?
        #if self.expired_at.blank?
        #  expired_period = self.manifestation.reservation_expired_period(self.user)
        #  self.expired_at = (expired_period + 1).days.from_now.beginning_of_day
        unless expired_at.blank?
          errors[:base] << I18n.t('reserve.invalid_date') if self.expired_at.beginning_of_day < Time.zone.now
        end
      end
    end
  end

  def do_request
    self.update_attributes({:request_status_type => RequestStatusType.where(:name => 'In Process').first})
  end

  def new_reserve
    library = Library.find(self.receipt_library_id)
    self.send_message('accepted')  
    if self.available_for_checkout?    
      items = self.manifestation.items_ordered_for_retain(library) rescue nil
      items.each do |item|
       if item.available_for_retain? && !item.reserved?
          self.item = item
          if item.shelf.library == library
            self.sm_retain!
            self.send_message('retained')
          else
            self.sm_process!
            InterLibraryLoan.new.request_for_reserve(item, library)
          end
          return
        end
      end
      self.sm_request!
    else
      self.sm_request!
    end
  end

  def manifestation_must_include_item
    unless item_id.blank?
      item = Item.find(item_id) rescue nil
      errors[:base] << I18n.t('reserve.invalid_item') unless manifestation.items.include?(item)
    end
  end

  def next_reservation
    manifestation.reserves.where('reserves.id != ?', self.id).order('reserves.position').first
  end

  def retain
    # TODO: 「取り置き中」の状態を正しく表す
    self.item.retain_item!
    self.update_attribute(:request_status_type, RequestStatusType.where(:name => 'In Process').first)
    self.remove_from_list
  end

  def revert_request
    self.item_id = nil
    self.sm_request!
    self.insert_at(1)
    send_message('reverted')
  end

  def to_process
    # borrow from other library
    self.update_attribute(:request_status_type, RequestStatusType.where(:name => 'In Process').first)
  end

  def expire
    self.update_attributes!({:request_status_type => RequestStatusType.where(:name => 'Expired').first, :canceled_at => Time.zone.now})
    self.remove_from_list
    logger.info "#{Time.zone.now} reserve_id #{self.id} expired!"
  end

  def cancel
    if self.item
      self.item.cancel_retain!
      current_user = User.where(:username => 'admin').first
      self.item.retain(current_user) if self.item.manifestation.next_reservation
    end
    self.update_attributes!({:request_status_type => RequestStatusType.where(:name => 'Cannot Fulfill Request').first, :canceled_at => Time.zone.now})
    self.remove_from_list
  end

  def checkout
    self.update_attributes!({:request_status_type => RequestStatusType.where(:name => 'Available For Pickup').first, :checked_out_at => Time.zone.now})
    self.remove_from_list
  end
  
  def available_for_checkout?
    library = Library.find(self.receipt_library_id)
    items = Manifestation.find(self.manifestation_id).items_ordered_for_retain(library)
    reserve_position = Reserve.waiting.where("manifestation_id = ? AND position >= ? AND item_id IS NULL", self.manifestation_id, self.position).count
    i = 1
    items.each do |item|
      if item.available_for_retain? && !item.reserved?
        return true if i >= reserve_position
        i += 1
      end
    end
    false
  end

  def available_for_update?
    reserve = Reserve.find(self.id)
    #errors[:base] << I18n.t('reserve.expired_at_of_this_user_is_over') if self.expired_at and self.user.expired_at and self.user.expired_at < self.expired_at
    return false if self.expired_at and self.user.expired_at and self.user.expired_at < self.expired_at
    true
  end

  def send_message(status)
    system_user = User.find(1) # TODO: システムからのメッセージの発信者
    Reserve.transaction do
      case status
      when 'accepted'
        if SystemConfiguration.get("send_message.reservation_accepted_for_patron")
          message_template_to_patron = MessageTemplate.localized_template('reservation_accepted_for_patron', self.user.locale)
          request = MessageRequest.create!(:sender => system_user, :receiver => self.user, :message_template => message_template_to_patron)
          request.save_message_body(:manifestations => Array[self.manifestation], :user => self.user)
          request.sm_send_message!
        end
        if SystemConfiguration.get("send_message.reservation_accepted_for_library")
          message_template_to_library = MessageTemplate.localized_template('reservation_accepted_for_library', self.user.locale)
          request = MessageRequest.create!(:sender => system_user, :receiver => system_user, :message_template => message_template_to_library)
          request.save_message_body(:manifestations => Array[self.manifestation], :user => self.user)
          request.sm_send_message!
        end
      when 'canceled'
        if SystemConfiguration.get("send_message.reservation_canceled_for_patron")
          message_template_to_patron = MessageTemplate.localized_template('reservation_canceled_for_patron', self.user.locale)
          request = MessageRequest.create!(:sender => system_user, :receiver => self.user, :message_template => message_template_to_patron)
          request.save_message_body(:manifestations => Array[self.manifestation], :user => self.user)
          request.sm_send_message!
        end
        if SystemConfiguration.get("send_message.reservation_canceled_for_library")
          message_template_to_library = MessageTemplate.localized_template('reservation_canceled_for_library', self.user.locale)
          request = MessageRequest.create!(:sender => system_user, :receiver => system_user, :message_template => message_template_to_library)
          request.save_message_body(:manifestations => Array[self.manifestation], :user => self.user)
          request.sm_send_message!
        end
      when 'expired'
        message_template_to_patron = MessageTemplate.localized_template('reservation_expired_for_patron', self.user.locale)
        request = MessageRequest.new(:sender => system_user, :receiver => self.user, :message_template => message_template_to_patron)
        request.save_message_body(:manifestations => Array[self.manifestation], :user => self.user)
        request.send_later(:sm_send_message!)
        self.update_attribute(:expiration_notice_to_patron, true)
=begin
        if SystemConfiguration.get("send_message.reservation_expired_for_library")
          message_template_to_library = MessageTemplate.localized_template('reservation_expired_for_library', self.user.locale)
          request = MessageRequest.create!(:sender => system_user, :receiver => self.user, :message_template => message_template_to_library)
            request.save_message_body(:manifestations => Array[self.manifestation], :user => self.user)
          request.sm_send_message!
          self.not_sent_expiration_notice_to_library.each do |reserve|
            self.update_attribute(:expiration_notice_to_library, true)
          end
        end
        if SystemConfiguration.get("send_message.reservation_expired_for_patron")
          message_template_to_patron = MessageTemplate.localized_template('reservation_expired_for_patron', self.user.locale)
          request = MessageRequest.create!(:sender => system_user, :receiver => self.user, :message_template => message_template_to_patron)
          request.save_message_body(:manifestations => Array[self.manifestation], :user => self.user)
          request.sm_send_message!
          self.update_attribute(:expiration_notice_to_patron, true)
        end
=end
      when 'retained'
        if SystemConfiguration.get("send_message.item_received_for_patron")
          message_template_for_patron = MessageTemplate.localized_template('item_received_for_patron', self.user.locale)
          request = MessageRequest.create!(:sender => system_user, :receiver => user, :message_template => message_template_for_patron)
          request.save_message_body(:manifestations => Array[self.manifestation], :user => self.user)
          request.sm_send_message!
        end
        if SystemConfiguration.get("send_message.item_received_for_library")
          message_template_for_library = MessageTemplate.localized_template('item_received_for_library', self.user.locale)
          request = MessageRequest.create!(:sender => system_user, :receiver => system_user, :message_template => message_template_for_library)
          request.save_message_body(:manifestations => Array[self.manifestation], :user => self.user)
          request.sm_send_message!
        end
=begin
        message_template_to_patron = MessageTemplate.localized_template('retained_manifestations', self.user.locale)
        request = MessageRequest.new(:sender => system_user, :receiver => self.user, :message_template => message_template_to_patron)
        request.save_message_body(:manifestations => Array[self.manifestation], :user => self.user)
        request.send_later(:sm_send_message!)
        self.update_attribute(:expiration_notice_to_patron, true)
=end
      when 'reverted'
        if SystemConfiguration.get("send_message.reserve_reverted_for_patron")
          message_template_for_patron = MessageTemplate.localized_template('reserve_reverted_for_patron', self.user.locale)
          request = MessageRequest.create!(:sender => system_user, :receiver => user, :message_template => message_template_for_patron)
          request.save_message_body(:manifestations => Array[self.manifestation], :user => self.user)
          request.sm_send_message!
        end
        if SystemConfiguration.get("send_message.reserve_reverted_for_library")
          message_template_for_library = MessageTemplate.localized_template('reserve_reverted_for_library', self.user.locale)
          request = MessageRequest.create!(:sender => system_user, :receiver => system_user, :message_template => message_template_for_library)
          request.save_message_body(:manifestations => Array[self.manifestation], :user => self.user)
          request.sm_send_message!
        end
      else
        raise 'status not defined'
      end
    end
    rescue Exception => e
      logger.error e
  end

  def self.send_message_to_library(status, options = {})
    system_user = User.find(1) # TODO: システムからのメッセージの発信者
    case status
    when 'expired'
      if SystemConfiguration.get("send_message.reservation_expired_for_library")
        message_template_to_library = MessageTemplate.localized_template('reservation_expired_for_library', system_user.locale)
        request = MessageRequest.create!(:sender => system_user, :receiver => system_user, :message_template => message_template_to_library)
        request.save_message_body(:manifestations => options[:manifestations])
        request.sm_send_message!
        self.not_sent_expiration_notice_to_library.each do |reserve|
          reserve.update_attribute(:expiration_notice_to_library, true)
        end
      end
    #when 'canceled'
    #  if SystemConfiguration.get("send_message.reservation_canceled_for_library")
    #    message_template_to_library = MessageTemplate.localized_template('reservation_canceled_for_library', system_user.locale)
    #    request = MessageRequest.create!(:sender => system_user, :receiver => system_user, :message_template => message_template_to_library)
    #    request.save_message_body(:manifestations => self.not_sent_expiration_notice_to_library.collect(&:manifestation))
    #    self.not_sent_cancel_notice_to_library.each do |reserve|
    #      reserve.update_attribute(:expiration_notice_to_library, true)
    #    end
    #  end
    else
      raise 'status not defined'
    end
  end

  def self.expire
    Reserve.transaction do
      self.will_expire_pending(Time.zone.now.beginning_of_day).map{|r| r.sm_expire!}
      self.will_expire_requested(Time.zone.now.beginning_of_day).map{|r| r.sm_expire!}
      self.will_expire_retained(Time.zone.now.beginning_of_day).map{|r| r.sm_expire!; r.item.set_next_reservation}

      # キューに登録した時点では本文は作られないので
      # 予約の連絡をすませたかどうかを識別できるようにしなければならない
      # reserve.send_message('expired')
      User.find_each do |user|
        unless user.reserves.not_sent_expiration_notice_to_patron.empty?
          if SystemConfiguration.get("send_message.reservation_expired_for_patron")
            user.send_message('reservation_expired_for_patron', :manifestations => user.reserves.not_sent_expiration_notice_to_patron.collect(&:manifestation))
          end
        end
      end
      unless Reserve.not_sent_expiration_notice_to_library.empty?
        Reserve.send_message_to_library('expired', :manifestations => Reserve.not_sent_expiration_notice_to_library.collect(&:manifestation))
      end
    end
  #rescue
  #  logger.info "#{Time.zone.now} expiring reservations failed!"
  end

  def available_for_reservation?
    if self.manifestation
      if self.manifestation.is_reserved_by(self.user)
        errors[:base] << I18n.t('reserve.this_manifestation_is_already_reserved')
      end
      if self.user.try(:reached_reservation_limit?, self.manifestation)
        errors[:base] << I18n.t('reserve.excessed_reservation_limit')
      end

      expired_period = self.manifestation.try(:reservation_expired_period, self.user)
      if expired_period.nil?
        errors[:base] << I18n.t('reserve.this_patron_cannot_reserve')
      end

      if self.user.locked_at
        errors[:base] << I18n.t('reserve.this_user_is_locked')
      end

      if self.expired_at and self.user.expired_at
        if self.user.expired_at < self.expired_at
          errors[:base] << I18n.t('reserve.expired_at_of_this_user_is_over')
        end
      end
    end
  end

  def position_update(manifestation)
    reserves = Reserve.where(:manifestation_id => manifestation).can_change_position.order(:position)
    items = manifestation.items_ordered_for_retain.for_checkout
    items.delete_if{|item| !item.available_for_retain?}
    reserves.each do |reserve|
      if !items.blank?
        reserve.item = items.shift
        reserve.sm_retain!
      else
        reserve.item = nil
        reserve.sm_request!
        reserve.save
      end
    end
    rescue Exception => e
      logger.error "Failed to update reserve position: #{e}"
  end

  def retained_mail_title
    #MessageTemplate.localized_template('retained_manifestations', self.user.locale).title rescue nil
    MessageTemplate.localized_template('item_received_for_patron', self.user.locale).title rescue nil
  end

  def retained_mail_message
    #message = MessageTemplate.localized_template('retained_manifestations', self.user.locale)
    message = MessageTemplate.localized_template('item_received_for_patron', self.user.locale)
    options = {:manifestations => Array[self.manifestation], 
               :user => self.user,
               :receipt_library => Library.find(self.receipt_library_id),
               :locale => self.user.locale
              }
    return message.embed_body(options)
  end

  def self.information_type_ids
    information_types = [Reserve.mail_type_ids, Reserve.all_telephone_type_ids, Reserve.unnecessary_type_ids]
    return information_types
  end

  def self.unnecessary_type_ids
    return 0
  end

  def self.mail_type_ids
    return 1
  end

  def self.all_telephone_type_ids
    return [2, 3, 4, 5, 6, 7]
  end

  def self.informations(user)
    @informations = []
    @Type = Struct.new(:id, :display_name, :information)
    unless user.blank?
      @informations << @Type.new(1, I18n.t('activerecord.attributes.user.email'), user.email) unless user.email.blank?
      @informations << @Type.new(2, I18n.t('activerecord.attributes.patron.telephone_number_1'), user.patron.telephone_number_1) unless user.patron.telephone_number_1.blank?
      @informations << @Type.new(3, I18n.t('activerecord.attributes.patron.extelephone_number_1'), user.patron.extelephone_number_1) unless user.patron.extelephone_number_1.blank?
      @informations << @Type.new(4, I18n.t('activerecord.attributes.patron.fax_number_1'), user.patron.fax_number_1) unless user.patron.fax_number_1.blank?
      @informations << @Type.new(5, I18n.t('activerecord.attributes.patron.telephone_number_2'), user.patron.telephone_number_2) unless user.patron.telephone_number_2.blank?
      @informations << @Type.new(6, I18n.t('activerecord.attributes.patron.extelephone_number_2'), user.patron.extelephone_number_2) unless user.patron.extelephone_number_2.blank?
      @informations << @Type.new(7, I18n.t('activerecord.attributes.patron.fax_number_2'), user.patron.fax_number_2) unless user.patron.fax_number_2.blank?
    end
    @informations << @Type.new(0, I18n.t('activerecord.attributes.reserve.unnecessary'), '')
    return @informations
  end

  def self.get_information_type(reserve)
    user = User.find(reserve.user_id)
    information_type = nil
    case reserve.information_type_id
    when 1
      information_type = user.email unless user.email.blank?
    when 2
      information_type = user.patron.telephone_number_1 unless user.patron.telephone_number_1.blank? 
    when 3
      information_type = user.patron.extelephone_number_1 unless user.patron.extelephone_number_1.blank?
    when 4
      information_type = user.patron.fax_number_1 unless user.patron.fax_number_1.blank?
    when 5
      information_type = user.patron.telephone_number_2 unless user.patron.telephone_number_2.blank?
    when 6
      information_type = user.patron.extelephone_number_2 unless user.patron.extelephone_number_2.blank?
    when 7
      information_type = user.patron.fax_number_2 unless user.patron.fax_number_2.blank?
    end
    return information_type
  end

  def self.states
    @states = ['requested', 'in_process', 'retained', 'completed', 'canceled', 'expired']
    return @states
  end

  def self.show_user_states
    @states = ['requested', 'retained', 'in_process']
    return @states
  end

  def can_checkout?
    return true if ['requested', 'retained', 'in_process'].include?(self.state)
    false
  end 

  def can_cancel?
    return true if ['requested', 'retained'].include?(self.state)
    false
  end

  def can_edit?
    return true if ['requested', 'in_process', 'retained'].include?(self.state)
    false
  end

  def user_can_show?
    return true if ['requested', 'retained', 'in_process'].include?(self.state)
    false
  end 

  # output
  def self.get_reserve(reserve, current_user)
    receipt_library = Library.find(reserve.receipt_library_id)

    report = ThinReports::Report.new :layout => File.join(Rails.root, 'report', 'reserve.tlf')
    report.start_new_page do |page|
      # library info
      user = reserve.user.user_number
      if SystemConfiguration.get("reserve_print.old") == true and  reserve.user.patron.date_of_birth
        age = (Time.now.strftime("%Y%m%d").to_f - reserve.user.patron.date_of_birth.strftime("%Y%m%d").to_f) / 10000
        age = age.to_i
        user = user + '(' + age.to_s + I18n.t('activerecord.attributes.patron.old')  +')'
      end
      page.item(:library).value(LibraryGroup.system_name(@locale))
      page.item(:date).value(Time.now)
      page.item(:created_at).value(reserve.created_at.strftime("%Y/%m/%d"))
      page.item(:expired_at).value(reserve.expired_at.strftime("%Y/%m/%d"))
      page.item(:user).value(user)
      page.item(:receipt_library).value(receipt_library.display_name)
      page.item(:receipt_library_telephone_number_1).value(receipt_library.telephone_number_1)
      page.item(:receipt_library_telephone_number_2).value(receipt_library.telephone_number_2)
      page.item(:information_type).value(I18n.t(i18n_information_type(reserve.information_type_id).strip_tags))
      page.item(:user_information).value(Reserve.get_information_type(reserve))
      # book info
      page.item(:title).value(reserve.manifestation.original_title)
      page.item(:creater).value(patrons_list(reserve.manifestation.creators.readable_by(current_user), {:itemprop => 'author', :nolink => true}))
      page.item(:publisher).value(patrons_list(reserve.manifestation.publishers.readable_by(current_user), {:itemprop => 'publisher', :nolink => true}))
      page.item(:price).value(reserve.manifestation.price)
      page.item(:page).value(reserve.manifestation.number_of_pages.to_s + 'p') if reserve.manifestation.number_of_pages
      page.item(:size).value(reserve.manifestation.height.to_s + 'cm') if reserve.manifestation.height
      page.item(:isbn).value(reserve.manifestation.isbn)
    end
    return report
  end

  def self.get_reserves(user, current_user)
    if current_user.has_role?('Librarian')
      reserves = Reserve.show_reserves.where(:user_id => user.id).order('expired_at Desc')
    else
      reserves = Reserve.user_show_reserves.where(:user_id => user.id).order('expired_at Desc')
    end
    report = ThinReports::Report.new :layout => File.join(Rails.root, 'report', 'reservelist_user.tlf')
    report.layout.config.list(:list) do
      events.on :footer_insert do |e|
        e.section.item(:total).value(reserves.length)
        e.section.item(:date).value(Time.now)
      end
    end
    report.start_new_page do |page|
      page.item(:library).value(LibraryGroup.system_name(@locale))
      set_user = user.patron.full_name
      if SystemConfiguration.get("reserve_print.old") == true and user.patron.date_of_birth
        age = (Time.now.strftime("%Y%m%d").to_f - user.patron.date_of_birth.strftime("%Y%m%d").to_f) / 10000
        age = age.to_i
        set_user =set_user + '(' + age.to_s + I18n.t('activerecord.attributes.patron.old')  +')'
      end
      page.item(:user).value(set_user)
      user_library = Library.find(user.library_id)
      page.item(:user_library).value(user_library.display_name)
      page.item(:user_library_telephone_number_1).value(user_library.telephone_number_1)
      page.item(:user_library_telephone_number_2).value(user_library.telephone_number_2)
      page.item(:user_telephone_number_1_1).value(user.patron.telephone_number_1)
      page.item(:user_telephone_number_1_2).value(user.patron.extelephone_number_1)
      page.item(:user_telephone_number_1_3).value(user.patron.fax_number_1)
      page.item(:user_telephone_number_2_1).value(user.patron.telephone_number_2)
      page.item(:user_telephone_number_2_2).value(user.patron.extelephone_number_2)
      page.item(:user_telephone_number_2_3).value(user.patron.fax_number_2)
      page.item(:user_email).value(user.email)

      reserves.each do |reserve|
        page.list(:list).add_row do |row|
          row.item(:title).value(reserve.manifestation.original_title)
          row.item(:state).value(I18n.t(i18n_state(reserve.state).strip_tags))
          row.item(:receipt_library).value(Library.find(reserve.receipt_library_id).display_name)
          row.item(:information_type).value(I18n.t(i18n_information_type(reserve.information_type_id).strip_tags))
          row.item(:expired_at).value(reserve.expired_at.strftime("%Y/%m/%d"))
        end
      end
    end
    return report
  end

  def self.get_reserve_list_user_tsv(user_id, current_user)
    data = String.new
    data << "\xEF\xBB\xBF".force_encoding("UTF-8") + "\n"
    columns = [
      [:state,'activerecord.attributes.reserve.state'],
      [:receipt_library, 'activerecord.attributes.reserve.receipt_library'],
      [:title, 'activerecord.attributes.manifestation.original_title'],
      [:expired_at,'activerecord.attributes.reserve.expired_at2'],
      [:user, 'activerecord.attributes.reserve.user'],
      [:information_type, 'activerecord.attributes.reserve.information_type'],
    ]

    # title column
    row = columns.map {|column| I18n.t(column[1])}
    data << '"'+row.join("\"\t\"")+"\"\n"

    if current_user.has_role?('Librarian')
      states = Reserve.states
    else
      states = Reserve.show_user_states
    end
    states.each do |state|
      library = Library.real.collect{|library| library.id}
      information_type_ids = Reserve.information_type_ids
      reserves = Reserve.where(:user_id => user_id, :state => state, :receipt_library_id => library, :information_type_id => information_type_ids).order('expired_at ASC').includes(:manifestation)
      # set
      reserves.each do |reserve|
        row = []
        columns.each do |column|
          case column[0]
          when :state
            row << I18n.t(i18n_state(state).strip_tags)
          when :receipt_library
            row << Library.find(reserve.receipt_library_id).display_name
          when :title
            row << reserve.manifestation.original_title
          when :expired_at
            row << reserve.expired_at.strftime("%Y/%m/%d")
          when :user
            user = reserve.user.patron.full_name
            if SystemConfiguration.get("reserve_print.old") == true and  reserve.user.patron.date_of_birth
              age = (Time.now.strftime("%Y%m%d").to_f - reserve.user.patron.date_of_birth.strftime("%Y%m%d").to_f) / 10000
              age = age.to_i
              user = user + '(' + age.to_s + I18n.t('activerecord.attributes.patron.old')  +')'
            end
            row << user
          when :information_type
            information_type = I18n.t(i18n_information_type(reserve.information_type_id).strip_tags)
            information_type += ': ' + Reserve.get_information_type(reserve) if reserve.information_type_id != 0 and !Reserve.get_information_type(reserve).nil?
            row << information_type
          end
        end
        data << '"'+row.join("\"\t\"")+"\"\n"
      end
    end
    return data
  end

  def self.get_reserve_list_all_pdf(query, states, library, type)
    report = ThinReports::Report.new :layout => File.join(Rails.root, 'report', 'reservelist.tlf')

    # set page_num
    report.events.on :page_create do |e|
      e.page.item(:page).value(e.page.no)
    end
    report.events.on :generate do |e|
      e.pages.each do |page|
        page.item(:total).value(e.report.page_count)
      end
    end

    report.start_new_page do |page|
      page.item(:date).value(Time.now)

      before_state = nil
      states.each do |state|
        reserves = []
        error_condition = true if states.blank? or library.blank? or type.blank?
        if query.blank? or error_condition
          reserves = Reserve.where(:state => state, :receipt_library_id => library, :information_type_id => type).order('expired_at ASC').includes(:manifestation)
        else
          reserves = Reserve.search do
            fulltext query
            with(:state).equal_to(state)
            with(:receipt_library_id, library) unless library.blank?
            with(:information_type_id, type) unless type.blank?
            order_by(:expired_at, :asc)
          end.results
        end

        before_receipt_library = nil
        unless reserves.blank?
          reserves.each do |r|
            page.list(:list).add_row do |row|
             row.item(:not_found).hide
             if before_state == state
               row.item(:state_line).hide
               row.item(:state).hide
             end
             if before_receipt_library == r.receipt_library_id and before_state == state
               row.item(:receipt_library_line).hide
               row.item(:receipt_library).hide
             end
               row.item(:state).value(I18n.t(i18n_state(state).strip_tags))
               row.item(:receipt_library).value(Library.find(r.receipt_library_id).display_name)
               row.item(:title).value(r.manifestation.original_title)
               row.item(:expired_at).value(r.expired_at.strftime("%Y/%m/%d"))
               user = r.user.patron.full_name
               if SystemConfiguration.get("reserve_print.old") == true and  r.user.patron.date_of_birth
                 age = (Time.now.strftime("%Y%m%d").to_f - r.user.patron.date_of_birth.strftime("%Y%m%d").to_f) / 10000
                 age = age.to_i
                 user = user + '(' + age.to_s + I18n.t('activerecord.attributes.patron.old')  +')'
               end
               row.item(:user).value(user)
               information_type = I18n.t(i18n_information_type(r.information_type_id).strip_tags)
               information_type += ': ' + Reserve.get_information_type(r) if r.information_type_id != 0 and !Reserve.get_information_type(r).nil?
               row.item(:information_type).value(information_type)
            end
            before_receipt_library = r.receipt_library_id
            before_state = state
          end
        else
          page.list(:list).add_row do |row|
            row.item(:state).value(I18n.t(i18n_state(state).strip_tags))
            row.item(:not_found).show
            row.item(:not_found).value(I18n.t('page.no_record_found'))
            row.item(:line2).hide
            row.item(:line3).hide
            row.item(:line4).hide
            row.item(:line5).hide
          end
        end
      end
      return report
    end
  end

  def self.get_reserve_list_all_tsv(query, states, library, type)
    data = String.new
    data << "\xEF\xBB\xBF".force_encoding("UTF-8") + "\n"
    columns = [
      [:state,'activerecord.attributes.reserve.state'],
      [:receipt_library, 'activerecord.attributes.reserve.receipt_library'],
      [:title, 'activerecord.attributes.manifestation.original_title'],
      [:expired_at,'activerecord.attributes.reserve.expired_at2'],
      [:user, 'activerecord.attributes.reserve.user'],
      [:information_type, 'activerecord.attributes.reserve.information_type'],
    ]

    # title column
    row = columns.map {|column| I18n.t(column[1])}
    data << '"'+row.join("\"\t\"")+"\"\n"

    states.each do |state|
      # get reserves
      error_condition = true if states.blank? or library.blank? or type.blank?
      if query.blank? or error_condition
        reserves = Reserve.where(:state => state, :receipt_library_id => library, :information_type_id => type).order('expired_at ASC').includes(:manifestation)
      else
        reserves = Reserve.search do
          fulltext query
          with(:state).equal_to(state)
          with(:receipt_library_id, library) unless library.blank?
          with(:information_type_id, type) unless type.blank?
          order_by(:expired_at, :asc)
        end.results
      end
      # set
      reserves.each do |reserve|
        row = []
        columns.each do |column|
          case column[0]
          when :state
            row << I18n.t(i18n_state(state).strip_tags)
          when :receipt_library
            row << Library.find(reserve.receipt_library_id).display_name
          when :title
            row << reserve.manifestation.original_title
          when :expired_at
            row << reserve.expired_at.strftime("%Y/%m/%d")
          when :user
            user = reserve.user.patron.full_name
            if SystemConfiguration.get("reserve_print.old") == true and  reserve.user.patron.date_of_birth
              age = (Time.now.strftime("%Y%m%d").to_f - reserve.user.patron.date_of_birth.strftime("%Y%m%d").to_f) / 10000
              age = age.to_i
              user = user + '(' + age.to_s + I18n.t('activerecord.attributes.patron.old')  +')'
            end
            row << user
          when :information_type
            information_type = I18n.t(i18n_information_type(reserve.information_type_id).strip_tags)
            information_type += ': ' + Reserve.get_information_type(reserve) if reserve.information_type_id != 0 and !Reserve.get_information_type(reserve).nil?
            row << information_type
          end
        end
        data << '"'+row.join("\"\t\"")+"\"\n"
      end
    end
    return data
  end

  
  def self.get_reservelist_pdf(displist)
    report = ThinReports::Report.new :layout => File.join(Rails.root, 'report', 'reservelist.tlf')

    # set page_number
    report.events.on :page_create do |e|
      e.page.item(:page).value(e.page.no)
    end
    report.events.on :generate do |e|
      e.pages.each do |page|
        page.item(:total).value(e.report.page_count)
      end
    end

    report.start_new_page do |page|
      page.item(:date).value(Time.now)
      before_state = nil

      displist.each do |d|
        before_receipt_library = nil
        unless d.reserves.blank?
          d.reserves.each do |r|
            page.list(:list).add_row do |row|
             row.item(:not_found).hide
             if before_state == d.state
               row.item(:state_line).hide
               row.item(:state).hide
             end
             if before_receipt_library == r.receipt_library_id and before_state == d.state
               row.item(:receipt_library_line).hide
               row.item(:receipt_library).hide
             end
               row.item(:state).value(I18n.t(i18n_state(d.state).strip_tags))
               row.item(:receipt_library).value(Library.find(r.receipt_library_id).display_name)
               row.item(:title).value(r.manifestation.original_title)
               row.item(:expired_at).value(r.expired_at.strftime("%Y/%m/%d"))
               user = r.user.patron.full_name
               if SystemConfiguration.get("reserve_print.old") == true and  r.user.patron.date_of_birth
                 age = (Time.now.strftime("%Y%m%d").to_f - r.user.patron.date_of_birth.strftime("%Y%m%d").to_f) / 10000
                 age = age.to_i
                 user = user + '(' + age.to_s + I18n.t('activerecord.attributes.patron.old')  +')'
               end
               row.item(:user).value(user)
               information_type = I18n.t(i18n_information_type(r.information_type_id).strip_tags)
               information_type += ': ' + Reserve.get_information_type(r) if r.information_type_id != 0 and !Reserve.get_information_type(r).nil?
               row.item(:information_type).value(information_type)
            end
            before_receipt_library = r.receipt_library_id
            before_state = d.state
          end
        else
          page.list(:list).add_row do |row|
            row.item(:state).value(I18n.t(i18n_state(d.state).strip_tags))
            row.item(:not_found).show
            row.item(:not_found).value(I18n.t('page.no_record_found'))
            row.item(:line2).hide
            row.item(:line3).hide
            row.item(:line4).hide
            row.item(:line5).hide
          end
        end
      end
      return report
    end
  end

  def self.get_reservelist_tsv(displist)
    @buf = String.new
    displist.each do |d|
      @buf << "\"" + I18n.t(i18n_state(d.state).strip_tags) + "\"" + "\n"
      @buf << "\"" + I18n.t('activerecord.attributes.manifestation.original_title') + "\"" + "\t" +
        "\"" + I18n.t('activerecord.attributes.user.user_number') + "\"" + "\t" +
        "\"" + I18n.t('activerecord.models.user') + "\"" + "\t" +
        "\"" + I18n.t('activerecord.attributes.item.item_identifier') + "\"" + "\t" +
        "\n"
      d.reserves.each do |reserve|
        original_title = ""
        original_title = reserve.manifestation.original_title unless reserve.manifestation.original_title.blank?
        user_number = ""
        user_number = reserve.user.user_number unless reserve.user.user_number.blank?
        full_name = ""
        full_name = reserve.user.patron.full_name unless reserve.user.patron.full_name.blank?
        if SystemConfiguration.get("reserve_print.old") == true and  reserve.user.patron.date_of_birth
          age = (Time.now.strftime("%Y%m%d").to_f - reserve.user.patron.date_of_birth.strftime("%Y%m%d").to_f) / 10000
          age = age.to_i
          full_name = full_name + '(' + age.to_s + I18n.t('activerecord.attributes.patron.old')  +')'
        end
        item_identifier = ""
        item_identifier = reserve.item.item_identifier if !reserve.item.blank? and !reserve.item.item_identifier.blank?
        @buf << "\"" + original_title + "\"" + "\t" +
                "\"" + user_number + "\"" + "\t" +
                "\"" + full_name + "\"" + "\t" +
                "\"" + item_identifier + "\"" + "\t" +
                "\n"
      end
      @buf << "\n"
    end
    return @buf
  end

  def self.get_retained_manifestation_list_pdf(retained_manifestations)
    report = ThinReports::Report.new :layout => File.join(Rails.root, 'report', 'retained_manifestations.tlf')

    # set page num
    report.events.on :page_create do |e|
      e.page.item(:page).value(e.page.no)
    end
    report.events.on :generate do |e|
      e.pages.each do |page|
        page.item(:total).value(e.report.page_count)
      end
    end
    # set
    report.start_new_page do |page|
      page.item(:date).value(Time.now)
      before_user = nil
      before_receipt_library = nil
      if retained_manifestations.size > 0
        retained_manifestations.each do |r|
          page.list(:list).add_row do |row|
            if before_user == r.user_id
              row.item(:line1).hide
              row.item(:user).hide
            end
            if before_receipt_library == r.receipt_library_id and before_user == r.user_id
              row.item(:line2).hide
              row.item(:receipt_library).hide
            end
            row.item(:receipt_library).value(Library.find(r.receipt_library_id).display_name)
            row.item(:title).value(r.manifestation.original_title)
            disp_name = r.user.patron.full_name
            if SystemConfiguration.get("reserve_print.old") == true and  r.user.patron.date_of_birth
              age = (Time.now.strftime("%Y%m%d").to_f - r.user.patron.date_of_birth.strftime("%Y%m%d").to_f) / 10000
              age = age.to_i
              disp_name = disp_name + '(' + age.to_s + I18n.t('activerecord.attributes.patron.old')  +')'
            end
            row.item(:user).value(disp_name)
            information_type = I18n.t(i18n_information_type(r.information_type_id).strip_tags)
            unless r.information_type_id == Reserve.unnecessary_type_ids
              information_type += ': '
              information_type += Reserve.get_information_type(r) unless Reserve.get_information_type(r).blank?
            end
            row.item(:information_type).value(information_type)
          end
          before_user = r.user_id
          before_receipt_library = r.receipt_library_id
        end
      end
    end
    return report
  end

 def self.get_retained_manifestation_list_tsv(retained_manifestations)
    data = String.new
    data << "\xEF\xBB\xBF".force_encoding("UTF-8") + "\n"
    columns = [
      [:user, 'activerecord.attributes.reserve.user'],
      [:receipt_library, 'activerecord.attributes.reserve.receipt_library'],
      [:title, 'activerecord.attributes.manifestation.original_title'],
      [:information_type, 'activerecord.attributes.reserve.information_type']
    ]

    # title column
    row = columns.map {|column| I18n.t(column[1])}
    data << '"'+row.join("\"\t\"")+"\"\n"

    retained_manifestations.each do |reserve|
      row = []
      columns.each do |column|
        case column[0]
        when :user
          disp_name = reserve.user.patron.full_name
          if SystemConfiguration.get("reserve_print.old") == true and  reserve.user.patron.date_of_birth
            age = (Time.now.strftime("%Y%m%d").to_f - reserve.user.patron.date_of_birth.strftime("%Y%m%d").to_f) / 10000
            age = age.to_i
            disp_name = disp_name + '(' + age.to_s + I18n.t('activerecord.attributes.patron.old')  +')'
          end
          row << disp_name
        when :receipt_library
          row << Library.find(reserve.receipt_library_id).display_name
        when :title
          row << reserve.manifestation.original_title
        when :information_type
          information_type = I18n.t(i18n_information_type(reserve.information_type_id).strip_tags)
          unless reserve.information_type_id == Reserve.unnecessary_type_ids
            information_type += ': '
            information_type += Reserve.get_information_type(reserve) unless Reserve.get_information_type(reserve).blank?
          end
          row << information_type
        end
      end
      data << '"'+row.join("\"\t\"")+"\"\n"
    end
    return data
  end
end

# == Schema Information
#
# Table name: reserves
#
#  id                           :integer         not null, primary key
#  user_id                      :integer         not null
#  manifestation_id             :integer         not null
#  item_id                      :integer
#  request_status_type_id       :integer         not null
#  checked_out_at               :datetime
#  created_at                   :datetime
#  updated_at                   :datetime
#  canceled_at                  :datetime
#  expired_at                   :datetime
#  deleted_at                   :datetime
#  state                        :string(255)
#  expiration_notice_to_patron  :boolean         default(FALSE)
#  expiration_notice_to_library :boolean         default(FALSE)
#

