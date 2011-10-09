class CheckedItem < ActiveRecord::Base
  belongs_to :item #, :validate => true
  belongs_to :basket #, :validate => true

  validates_associated :item, :basket, :on => :update
  validates_presence_of :item, :basket, :due_date, :on => :update
  validates_uniqueness_of :item_id, :scope => :basket_id
  validate :available_for_checkout?, :on => :create
 
  before_validation :set_due_date, :on => :create
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

    if self.item.not_for_loan?
      errors[:base] << I18n.t('activerecord.errors.messages.checked_item.not_available_for_checkout')
    end

    if self.in_transaction?
      errors[:base] << I18n.t('activerecord.errors.messages.checked_item.in_transcation')
    end

    if self.item.reserved?
      if self.item.manifestation.next_reservation.user == self.basket.user
        self.item.manifestation.next_reservation.sm_complete
      else
        errors[:base] << I18n.t('activerecord.errors.messages.checked_item.reserved_item_included')
      end
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
    while item.shelf.library.closed?(due_date)
      if item_checkout_type.set_due_date_before_closing_day
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

