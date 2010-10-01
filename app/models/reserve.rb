# -*- encoding: utf-8 -*-
class Reserve < ActiveRecord::Base
  scope :hold, :conditions => ['item_id IS NOT NULL']
  scope :not_hold, :conditions => ['item_id IS NULL']
  scope :waiting, :conditions => ['canceled_at IS NULL AND expired_at > ?', Time.zone.now], :order => 'id DESC'
  scope :completed, :conditions => ['checked_out_at IS NOT NULL']
  scope :canceled, :conditions => ['canceled_at IS NOT NULL']
  #scope :expired, lambda {|start_date, end_date| {:conditions => ['checked_out_at IS NULL AND expired_at > ? AND expired_at <= ?', start_date, end_date], :order => 'expired_at'}}
  scope :will_expire_retained, lambda {|datetime| {:conditions => ['checked_out_at IS NULL AND canceled_at IS NULL AND expired_at <= ? AND state = ?', datetime, 'retained'], :order => 'expired_at'}}
  scope :will_expire_pending, lambda {|datetime| {:conditions => ['checked_out_at IS NULL AND canceled_at IS NULL AND expired_at <= ? AND state = ?', datetime, 'pending'], :order => 'expired_at'}}
  scope :created, lambda {|start_date, end_date| {:conditions => ['created_at >= ? AND created_at < ?', start_date, end_date]}}
  #scope :expired_not_notified, :conditions => {:state => 'expired_not_notified'}
  #scope :expired_notified, :conditions => {:state => 'expired'}
  scope :not_sent_expiration_notice_to_patron, :conditions => {:state => 'expired', :expiration_notice_to_patron => false}
  scope :not_sent_expiration_notice_to_library, :conditions => {:state => 'expired', :expiration_notice_to_library => false}
  scope :sent_expiration_notice_to_patron, :conditions => {:state => 'expired', :expiration_notice_to_patron => true}
  scope :sent_expiration_notice_to_library, :conditions => {:state => 'expired', :expiration_notice_to_library => true}
  scope :not_sent_cancel_notice_to_patron, :conditions => {:state => 'canceled', :expiration_notice_to_patron => false}
  scope :not_sent_cancel_notice_to_library, :conditions => {:state => 'canceled', :expiration_notice_to_library => false}

  belongs_to :user, :validate => true
  belongs_to :manifestation, :validate => true
  belongs_to :librarian, :class_name => 'User', :validate => true
  belongs_to :item, :validate => true
  has_one :inter_library_loan
  belongs_to :request_status_type

  #acts_as_soft_deletable
  validates_associated :user, :librarian, :item, :request_status_type, :manifestation
  validates_presence_of :user, :manifestation, :request_status_type #, :expired_at
  #validates_uniqueness_of :manifestation_id, :scope => :user_id
  validate :manifestation_must_include_item
  before_validation :set_expired_at, :on => :create
  before_validation :set_item_and_manifestation, :on => :create

  attr_accessor :user_number, :item_identifier

  state_machine :initial => :pending do
    before_transition :pending => :requested, :do => :do_request
    before_transition [:pending, :requested, :retained] => :retained, :do => :retain
    before_transition [:pending ,:requested,  :retained] => :canceled, :do => :cancel
    before_transition [:pending, :requested, :retained] => :expired, :do => :expire
    before_transition :retained => :completed, :do => :checkout

    event :sm_request do
      transition :pending => :requested
    end

    event :sm_retain do
      transition [:pending, :requested, :retained] => :retained
    end

    event :sm_cancel do
      transition [:pending, :requested, :retained] => :canceled
    end
  
    event :sm_expire do
      transition [:pending, :requested, :retained] => :expired
    end

    event :sm_complete do
      transition :retained => :completed
    end
  end

  def self.per_page
    10
  end

  def set_item_and_manifestation
    item = Item.first(:conditions => {:item_identifier => item_identifier})
    manifestation = item.manifestation if item
  end

  def set_expired_at
    self.request_status_type = RequestStatusType.first(:conditions => {:name => 'In Process'})
    if self.user and self.manifestation
      if self.expired_at.blank?
        expired_period = self.manifestation.reservation_expired_period(self.user)
        self.expired_at = (expired_period + 1).days.from_now.beginning_of_day
      end
    end
  end

  def do_request
    self.update_attributes({:request_status_type => RequestStatusType.first(:conditions => {:name => 'In Process'})})
  end

  def manifestation_must_include_item
    unless item_id.blank?
      item = Item.find(item_id) rescue nil
      errors[:base] << I18n.t('reserve.invalid_item') unless manifestation.items.include?(item)
    end
  end

  def next_reservation
    self.manifestation.reserves.first(:conditions => ['reserves.id != ?', self.id], :order => ['reserves.created_at'])
  end

  #def self.reached_reservation_limit?(user, manifestation)
  #  return true if user.user_group.user_group_has_checkout_types.available_for_carrier_type(manifestation.carrier_type).all(:conditions => {:user_group_id => user.user_group.id}).collect(&:reservation_limit).max <= user.reserves.waiting.size
  #  false
  #end

  def retain
    # TODO: 「取り置き中」の状態を正しく表す
    self.update_attributes!({:request_status_type => RequestStatusType.first(:conditions => {:name => 'In Process'}), :checked_out_at => Time.zone.now})
  end

  def expire
    self.update_attributes!({:request_status_type => RequestStatusType.first(:conditions => {:name => 'Expired'}), :canceled_at => Time.zone.now})
    logger.info "#{Time.zone.now} reserve_id #{self.id} expired!"
  end

  def cancel
    self.update_attributes!({:request_status_type => RequestStatusType.first(:conditions => {:name => 'Cannot Fulfill Request'}), :canceled_at => Time.zone.now})
  end

  def checkout
    self.update_attributes!({:request_status_type => RequestStatusType.first(:conditions => {:name => 'Available For Pickup'}), :checked_out_at => Time.zone.now})
  end

  def send_message(status)
    system_user = User.find(1) # TODO: システムからのメッセージの発信者
    Reserve.transaction do
      case status
      when 'accepted'
        message_template_to_patron = MessageTemplate.localized_template('reservation_accepted', self.user.locale)
        request = MessageRequest.create!(:sender => system_user, :receiver => self.user, :message_template => message_template_to_patron)
        request.save_message_body(:manifestations => Array[self.manifestation])
        request.sm_send_message! # 受付時は即時送信
        message_template_to_library = MessageTemplate.localized_template('reservation_accepted', self.user.locale)
        request = MessageRequest.create!(:sender => system_user, :receiver => self.user, :message_template => message_template_to_library)
        request.save_message_body(:manifestations => Array[self.manifestation])
        request.sm_send_message! # 受付時は即時送信
      when 'canceled'
        message_template_to_patron = MessageTemplate.localized_template('reservation_canceled_for_patron', self.user.locale)
        request = MessageRequest.create!(:sender => system_user, :receiver => self.user, :message_template => message_template_to_patron)
        request.save_message_body(:manifestations => Array[self.manifestation])
        request.sm_send_message! # キャンセル時は即時送信
        message_template_to_library = MessageTemplate.localized_template('reservation_canceled_for_library', self.user.locale)
        request = MessageRequest.create!(:sender => system_user, :receiver => system_user, :message_template => message_template_to_library)
        request.save_message_body(:manifestations => Array[self.manifestation])
        request.sm_send_message! # キャンセル時は即時送信
      when 'expired'
        message_template_to_patron = MessageTemplate.localized_template('reservation_expired_for_patron', self.user.locale)
        request = MessageRequest.create!(:sender => system_user, :receiver => self.user, :message_template => message_template_to_patron)
        request.save_message_body(:manifestations => Array[self.manifestation])
        request.sm_send_message! # 期限切れ時は利用者にのみ即時送信
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
end
