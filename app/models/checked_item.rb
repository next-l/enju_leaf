class CheckedItem < ActiveRecord::Base
  belongs_to :item #, :validate => true
  belongs_to :basket #, :validate => true

  validates_associated :item, :basket, :on => :update
  validates_presence_of :item, :basket, :due_date, :on => :update
  validates_uniqueness_of :item_id, :scope => :basket_id
  validate :available_for_checkout?, :on => :create
 
  before_validation :set_due_date, :on => :create
  before_validation :check_reserve
  normalize_attributes :item_identifier

  attr_accessor :item_identifier, :ignore_restriction

  def available_for_checkout?
    if self.item.blank?
      errors[:base] << I18n.t('activerecord.errors.messages.checked_item.item_not_found')
      return false
    end

    if self.item.rent?
      errors[:base] << I18n.t('activerecord.errors.messages.checked_item.already_checked_out')
    end

    unless self.item.available_for_checkout?
      errors[:base] << I18n.t('activerecord.errors.messages.checked_item.not_available_for_checkout')
      return false
    end

    if self.item_checkout_type.blank?
      errors[:base] << I18n.t('activerecord.errors.messages.checked_item.this_group_cannot_checkout')
      return false
    end

    # ここまでは絶対に貸出ができない場合

    return true if self.ignore_restriction == "1"

    if self.item.reserved?
      if self.available_for_reserve_checkout?
        return true
      else
        errors[:base] << I18n.t('activerecord.errors.messages.checked_item.reserved_item_included')
        return false
      end
    end

    if self.item.not_for_loan?
      errors[:base] << I18n.t('activerecord.errors.messages.checked_item.not_available_for_checkout')
    end

    if self.in_transaction?
      errors[:base] << I18n.t('activerecord.errors.messages.checked_item.in_transcation')
    end

    checkout_count = self.basket.user.checked_item_count
    CheckoutType.all.each do |checkout_type|
      #carrier_type = self.item.manifestation.carrier_type
      if checkout_count[:"#{checkout_type.name}"] + self.basket.checked_items.count(:id) >= self.item_checkout_type.checkout_limit
        errors[:base] << I18n.t('activerecord.errors.messages.checked_item.excessed_checkout_limit')
        break
      end
    end
    
    return false unless errors[:base]
  end

  def item_checkout_type
    if item
      self.basket.user.user_group.user_group_has_checkout_types.available_for_item(item).first
    end
  end

  def set_due_date
    return nil unless self.item_checkout_type

    lending_rule = self.item.lending_rule(self.basket.user)
    return nil if lending_rule.nil?

    if lending_rule.fixed_due_date.blank?
      #self.due_date = item_checkout_type.checkout_period.days.since Time.zone.today
      self.due_date = lending_rule.loan_period.days.since Time.zone.now
    else
      #self.due_date = item_checkout_type.fixed_due_date
      self.due_date = lending_rule.fixed_due_date
    end
    # 返却期限日が閉館日の場合
    events = Event.find(:all, :conditions => ["? BETWEEN date_trunc('day', start_at) AND date_trunc('day', end_at)", due_date.beginning_of_day])
    checkin_before = false
    events.each do |e|
      checkin_before = true if e.event_category.move_checkin_date == 2
    end
    while item.shelf.library.closed?(due_date)
      if item_checkout_type.set_due_date_before_closing_day
        self.due_date = due_date.yesterday.end_of_day
      elsif checkin_before
        self.due_date = due_date.yesterday.end_of_day
      else
        self.due_date = due_date.tomorrow.end_of_day
      end
    end
    return self.due_date
  end

  def in_transaction?
    true if CheckedItem.where(:basket_id => self.basket.id, :item_id => self.item_id).first
  end

  def destroy_reservation(basket)
    if self.item.reserved?
      if self.item.manifestation.is_reserved_by(basket.user)
        reserve = Reserve.where(:user_id => basket.user_id, :manifestation_id => self.item.manifestation.id).first
        reserve.destroy
      end
    end
  end

  def available_for_reserve_checkout?
    reserve = Reserve.waiting.where(:manifestation_id => self.item.manifestation.id, :user_id => self.basket.user.id).first rescue nil
    retained_reserves = self.item.manifestation.reserves.hold
    if self.item.reserve.user == self.basket.user
      return true        
    elsif retained_reserves && retained_reserves.include?(reserve) && 
      retained_reserves.each do |r|
      end
      begin
        exchange_reserve_item(self.item, reserve)
        return true
      rescue
      end
    end
    false
  end

  def exchange_reserve_item(checkin_item, checkin_reserve)
    begin
      Reserve.transaction do 
        reserve = Reserve.waiting.where(:item_id => checkin_item.id).first rescue nil
        item = checkin_reserve.item
        checkin_reserve.item = checkin_item
        checkin_reserve.save!
        unless reserve.blank?
          reserve.item = item
          reserve.save!
        end
      end
    rescue Exception => e
      logger.error e
      raise e
    end
  end

  def check_reserve
    if self.item.manifestation.is_reserved_by(self.basket.user)
      reserve = Reserve.where(:manifestation_id => self.item.manifestation.id, :user_id => self.basket.user).first
      reserve.item = self.item 
      reserve.save
    end
  end
end

# == Schema Information
#
# Table name: checked_items
#
#  id         :integer         not null, primary key
#  item_id    :integer         not null
#  basket_id  :integer         not null
#  due_date   :datetime        not null
#  created_at :datetime
#  updated_at :datetime
#

