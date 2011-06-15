# -*- encoding: utf-8 -*-
class Reserve < ActiveRecord::Base
  scope :hold, :conditions => ['item_id IS NOT NULL']
  scope :not_hold, where(:item_id => nil)
  scope :waiting, :conditions => ['canceled_at IS NULL AND expired_at > ? AND state != ?', Time.zone.now, 'completed'], :order => 'id DESC'
  scope :completed, :conditions => ['checked_out_at IS NOT NULL']
  scope :canceled, :conditions => ['canceled_at IS NOT NULL']
  scope :will_expire_retained, lambda {|datetime| {:conditions => ['checked_out_at IS NULL AND canceled_at IS NULL AND expired_at <= ? AND state = ?', datetime, 'retained'], :order => 'expired_at'}}
  scope :will_expire_pending, lambda {|datetime| {:conditions => ['checked_out_at IS NULL AND canceled_at IS NULL AND expired_at <= ? AND state = ?', datetime, 'pending'], :order => 'expired_at'}}
  scope :created, lambda {|start_date, end_date| {:conditions => ['created_at >= ? AND created_at < ?', start_date, end_date]}}
  scope :not_sent_expiration_notice_to_patron, where(:state => 'expired', :expiration_notice_to_patron => false)
  scope :not_sent_expiration_notice_to_library, where(:state => 'expired', :expiration_notice_to_library => false)
  scope :sent_expiration_notice_to_patron, where(:state => 'expired', :expiration_notice_to_patron => true)
  scope :sent_expiration_notice_to_library, where(:state => 'expired', :expiration_notice_to_library => true)
  scope :not_sent_cancel_notice_to_patron, where(:state => 'canceled', :expiration_notice_to_patron => false)
  scope :not_sent_cancel_notice_to_library, where(:state => 'canceled', :expiration_notice_to_library => false)

  belongs_to :user, :validate => true
  belongs_to :manifestation, :validate => true
  belongs_to :librarian, :class_name => 'User', :validate => true
  belongs_to :item, :validate => true
  has_one :inter_library_loan
  belongs_to :request_status_type

  validates_associated :user, :librarian, :item, :request_status_type, :manifestation
  validates_presence_of :user, :manifestation, :request_status_type #, :expired_at
  #validates_uniqueness_of :manifestation_id, :scope => :user_id
  validates :expire_date, :format => {:with => /^\d+(-\d{0,2}){0,2}$/}, :allow_blank => true
  validate :manifestation_must_include_item
  validate :available_for_reservation?, :on => :create
  before_validation :set_item_and_manifestation, :on => :create
  before_validation :set_expired_at
  before_validation :set_request_status, :on => :create

  attr_accessor :user_number, :item_identifier

  state_machine :initial => :pending do
    before_transition :pending => :requested, :do => :do_request
    before_transition [:pending, :requested, :retained] => :retained, :do => :retain
    before_transition [:pending ,:requested, :retained] => :canceled, :do => :cancel
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
      transition [:pending, :requested, :retained] => :completed
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
    if expire_date.present?
      begin
        date = Time.zone.parse("#{expire_date}")
      rescue ArgumentError
        # TODO: 月日の省略時の既定値を決める
        begin
          date = Time.zone.parse("#{expire_date}-01")
        rescue ArgumentError
          date = Time.zone.parse("#{expire_date}-01-01")
        end
      end
      self.expired_at = date
    end

    if self.user and self.manifestation
      if self.canceled_at.blank?
        if self.expired_at.blank?
          expired_period = self.manifestation.reservation_expired_period(self.user)
          self.expired_at = (expired_period + 1).days.from_now.beginning_of_day
        elsif self.expired_at.beginning_of_day < Time.zone.now
          errors[:base] << I18n.t('reserve.invalid_date')
        end
      end
    end
  end

  def do_request
    self.update_attributes({:request_status_type => RequestStatusType.where(:name => 'In Process').first})
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

  def retain
    # TODO: 「取り置き中」の状態を正しく表す
    self.update_attributes!({:request_status_type => RequestStatusType.where(:name => 'In Process').first, :checked_out_at => Time.zone.now})
  end

  def expire
    self.update_attributes!({:request_status_type => RequestStatusType.where(:name => 'Expired').first, :canceled_at => Time.zone.now})
    logger.info "#{Time.zone.now} reserve_id #{self.id} expired!"
  end

  def cancel
    self.update_attributes!({:request_status_type => RequestStatusType.where(:name => 'Cannot Fulfill Request').first, :canceled_at => Time.zone.now})
  end

  def checkout
    self.update_attributes!({:request_status_type => RequestStatusType.where(:name => 'Available For Pickup').first, :checked_out_at => Time.zone.now})
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
        request = MessageRequest.create!(:sender => system_user, :receiver => system_user, :message_template => message_template_to_library)
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
end
