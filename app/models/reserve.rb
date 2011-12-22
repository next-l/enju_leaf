# -*- encoding: utf-8 -*-
class Reserve < ActiveRecord::Base
  scope :hold, where('item_id IS NOT NULL AND state = ?', 'retained')
  scope :not_hold, where(:item_id => nil)
  scope :waiting, where('canceled_at IS NULL AND expired_at > ? AND state != ? AND state != ?', Time.zone.now, 'completed', 'retained')
  scope :completed, where('checked_out_at IS NOT NULL')
  scope :canceled, where('canceled_at IS NOT NULL')
  scope :retained, where(:state => ['retained'], :retained => !true)
  scope :not_retained, where(:state => ['requested','pending'])
  scope :not_waiting, where(:state => ['retained','canceled','in_process', 'completed'])
  scope :will_expire_retained, lambda {|datetime| {:conditions => ['checked_out_at IS NULL AND canceled_at IS NULL AND expired_at <= ? AND state = ?', datetime, 'retained'], :order => 'expired_at'}}
  scope :will_expire_pending, lambda {|datetime| {:conditions => ['checked_out_at IS NULL AND canceled_at IS NULL AND expired_at <= ? AND state = ?', datetime, 'pending'], :order => 'expired_at'}}
  scope :created, lambda {|start_date, end_date| {:conditions => ['created_at >= ? AND created_at < ?', start_date, end_date]}}
  scope :not_sent_expiration_notice_to_patron, where(:state => 'expired', :expiration_notice_to_patron => false)
  scope :not_sent_expiration_notice_to_library, where(:state => 'expired', :expiration_notice_to_library => false)
  scope :sent_expiration_notice_to_patron, where(:state => 'expired', :expiration_notice_to_patron => true)
  scope :sent_expiration_notice_to_library, where(:state => 'expired', :expiration_notice_to_library => true)
  scope :not_sent_cancel_notice_to_patron, where(:state => 'canceled', :expiration_notice_to_patron => false)
  scope :not_sent_cancel_notice_to_library, where(:state => 'canceled', :expiration_notice_to_library => false)
  scope :previous_reserves, where(:state => ['requested', 'retained'])  
  acts_as_list :scope => :manifestation_id

  belongs_to :user, :validate => true
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
    before_transition [:pending, :requested, :retained] => :requested, :do => :do_request
    before_transition [:pending, :requested, :retained, :in_process] => :retained, :do => :retain
    before_transition [:pending, :requested] => :in_process, :do => :to_process
    before_transition [:pending ,:requested, :retained, :in_process] => :canceled, :do => :cancel
    before_transition [:pending, :requested, :retained, :in_process] => :expired, :do => :expire
    before_transition [:retained, :requested] => :completed, :do => :checkout


    event :sm_request do
      transition [:pending, :requested, :retained] => :requested
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
      transition [:canceled] => :expired
    end

    event :sm_complete do
      transition [:requested, :retained] => :completed
    end
  end

  def self.per_page
    10
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
    if self.available_for_checkout?    
      items = self.manifestation.items_ordered_for_retain(library) rescue nil
      items.each do |item|
        if item.available_for_checkout? && !item.reserved?
          self.item = item
          if item.shelf.library == library
            self.sm_retain
            self.save
          else
            self.sm_process
            self.save
            InterLibraryLoan.new.request_for_reserve(item, library)
          end
          return
        end
      end
      self.sm_request
    else
      self.sm_request
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
#    self.update_attributes!({:request_status_type => RequestStatusType.where(:name => 'In Process').first, :checked_out_at => Time.zone.now})
    self.item.retain_item!
    self.update_attributes!({:request_status_type => RequestStatusType.where(:name => 'In Process').first})
    self.remove_from_list
  end

  def to_process
    # borrow from other library
    self.update_attributes!({:request_status_type => RequestStatusType.where(:name => 'In Process').first})
  end

  def expire
    self.update_attributes!({:request_status_type => RequestStatusType.where(:name => 'Expired').first, :canceled_at => Time.zone.now})
    self.remove_from_list
    logger.info "#{Time.zone.now} reserve_id #{self.id} expired!"
  end

  def cancel
    if self.item
      self.item.cancel_retain!
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
      if item.available_for_checkout? && !item.reserved?
        return true if i >= reserve_position
        i += 1
      end
    end
    false
  end

  def send_message(status)
    system_user = User.find(1) # TODO: システムからのメッセージの発信者
    Reserve.transaction do
      case status
      when 'accepted'
        message_template_to_patron = MessageTemplate.localized_template('reservation_accepted_for_patron', self.user.locale)
        request = MessageRequest.create!(:sender => system_user, :receiver => self.user, :message_template => message_template_to_patron)
        request.save_message_body(:manifestations => Array[self.manifestation], :user => self.user)
        request.sm_send_message! # 受付時は即時送信
        message_template_to_library = MessageTemplate.localized_template('reservation_accepted_for_library', self.user.locale)
        request = MessageRequest.create!(:sender => system_user, :receiver => system_user, :message_template => message_template_to_library)
        request.save_message_body(:manifestations => Array[self.manifestation], :user => self.user)
        request.sm_send_message! # 受付時は即時送信
      when 'canceled'
        message_template_to_patron = MessageTemplate.localized_template('reservation_canceled_for_patron', self.user.locale)
        request = MessageRequest.create!(:sender => system_user, :receiver => self.user, :message_template => message_template_to_patron)
        request.save_message_body(:manifestations => Array[self.manifestation], :user => self.user)
        request.sm_send_message! # キャンセル時は即時送信
        message_template_to_library = MessageTemplate.localized_template('reservation_canceled_for_library', self.user.locale)
        request = MessageRequest.create!(:sender => system_user, :receiver => system_user, :message_template => message_template_to_library)
        request.save_message_body(:manifestations => Array[self.manifestation], :user => self.user)
        request.sm_send_message! # キャンセル時は即時送信
      when 'expired'
        message_template_to_patron = MessageTemplate.localized_template('reservation_expired_for_patron', self.user.locale)
        request = MessageRequest.create!(:sender => system_user, :receiver => self.user, :message_template => message_template_to_patron)
        request.save_message_body(:manifestations => Array[self.manifestation], :user => self.user)
        request.sm_send_message! # 期限切れ時は利用者にのみ即時送信
        self.update_attribute(:expiration_notice_to_patron, true)
      when 'retained'
        message_template_to_patron = MessageTemplate.localized_template('retained_manifestations', self.user.locale)
        request = MessageRequest.create!(:sender => system_user, :receiver => self.user, :message_template => message_template_to_patron)
        request.save_message_body(:manifestations => Array[self.manifestation], :user => self.user)
        request.sm_send_message! # 貸出準備ができたら利用者にのみ即時送信
        self.update_attribute(:expiration_notice_to_patron, true)
      else
        raise 'status not defined'
      end
    end
  end

  def self.send_message_to_library(status, options = {})
    system_user = User.find(1) # TODO: システムからのメッセージの発信者
    case status
    when 'expired'
      message_template_to_library = MessageTemplate.localized_template('reservation_expired_for_library', system_user.locale)
      request = MessageRequest.create!(:sender => system_user, :receiver => system_user, :message_template => message_template_to_library)
      request.save_message_body(:manifestations => options[:manifestations])
      self.not_sent_expiration_notice_to_library.each do |reserve|
        reserve.update_attribute(:expiration_notice_to_library, true)
      end
    #when 'canceled'
    #  message_template_to_library = MessageTemplate.localized_template('reservation_canceled_for_library', system_user.locale)
    #  request = MessageRequest.create!(:sender => system_user, :receiver => system_user, :message_template => message_template_to_library)
    #  request.save_message_body(:manifestations => self.not_sent_expiration_notice_to_library.collect(&:manifestation))
    #  self.not_sent_cancel_notice_to_library.each do |reserve|
    #    reserve.update_attribute(:expiration_notice_to_library, true)
    #  end
    else
      raise 'status not defined'
    end
  end

  def self.expire
    Reserve.transaction do
      self.will_expire_retained(Time.zone.now.beginning_of_day).map{|r| r.sm_expire!}
      self.will_expire_pending(Time.zone.now.beginning_of_day).map{|r| r.sm_expire!}

      # キューに登録した時点では本文は作られないので
      # 予約の連絡をすませたかどうかを識別できるようにしなければならない
      # reserve.send_message('expired')
      User.find_each do |user|
        unless user.reserves.not_sent_expiration_notice_to_patron.empty?
          user.send_message('reservation_expired_for_patron', :manifestations => user.reserves.not_sent_expiration_notice_to_patron.collect(&:manifestation))
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
    end
  end

  def position_update(manifestation)
    reserves = Reserve.where(:manifestation_id => manifestation).waiting.order(:position)
    items = manifestation.items_ordered_for_retain.for_checkout
    items.delete_if{|item| !item.available_for_checkout?}
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
    MessageTemplate.localized_template('retained_manifestations', self.user.locale).title rescue nil
  end

  def retained_mail_message
    message = MessageTemplate.localized_template('retained_manifestations', self.user.locale)
    options = {:manifestations => Array[self.manifestation], 
               :user => self.user,
               :receipt_library => Library.find(self.receipt_library_id),
               :locale => self.user.locale
              }
    return message.embed_body(options)
  end

  # TODO
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

  def self.get_information_method(reserve)
    user = User.find(reserve.user_id)
    @information_method = nil
    case reserve.information_type_id
    when 1
      @information_method = user.email unless user.email.blank?
    when 2
      @information_method = user.patron.telephone_number_1 unless user.patron.telephone_number_1.blank? 
    when 3
      @information_method = user.patron.extelephone_number_1 unless user.patron.extelephone_number_1.blank?
    when 4
      @information_method = user.patron.fax_number_1 unless user.patron.fax_number_1.blank?
    when 5
      @information_method = user.patron.telephone_number_2 unless user.patron.telephone_number_2.blank?
    when 6
      @information_method = user.patron.extelephone_number_2 unless user.patron.extelephone_number_2.blank?
    when 7
      @information_method = user.patron.fax_number_2 unless user.patron.fax_number_2.blank?
    end
    return @information_method
  end

  def self.information_types
    @information_types = [0, 1, 2]
    return @information_types
  end

  def self.states
    @states = ['requested', 'retained', 'in_process', 'completed', 'canceled', 'expired']
    return @states
  end

  def can_output?
    return true if ['requested', 'retained'].include?(self.state)
    false 
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

