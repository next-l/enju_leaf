class CheckedItem < ApplicationRecord
  belongs_to :item, optional: true
  belongs_to :basket
  belongs_to :librarian, class_name: 'User', optional: true

  validates_associated :item, :basket, on: :update
  validates :item, :basket, :due_date, presence: { on: :update }
  validates :item_id, uniqueness: { scope: :basket_id }
  validate :available_for_checkout?, on: :create
  validates :due_date_string, format: {with: /\A\[{0,1}\d+([\/-]\d{0,2}){0,2}\]{0,1}\z/}, allow_blank: true
  validate :check_due_date
 
  before_validation :set_item
  before_validation :set_due_date, on: :create
  strip_attributes only: :item_identifier

  # attr_protected :user_id
  attr_accessor :item_identifier, :ignore_restriction, :due_date_string

  def available_for_checkout?
    if item.blank?
      errors.add(:base, I18n.t('activerecord.errors.messages.checked_item.item_not_found'))
      return false
    end

    if item.rent?
      unless item.circulation_status.name == 'Missing'
        errors.add(:base, I18n.t('activerecord.errors.messages.checked_item.already_checked_out'))
      end
    end

    unless item.available_for_checkout?
      if item.circulation_status.name == 'Missing'
        item.circulation_status = CirculationStatus.find_by(name: 'Available On Shelf')
        item.save
        set_due_date
      else
        errors.add(:base, I18n.t('activerecord.errors.messages.checked_item.not_available_for_checkout'))
        return false
      end
    end

    if item_checkout_type.blank?
      errors.add(:base, I18n.t('activerecord.errors.messages.checked_item.this_group_cannot_checkout'))
      return false
    end
    # ここまでは絶対に貸出ができない場合

    return true if ignore_restriction == "1"

    if item.not_for_loan?
      errors.add(:base, I18n.t('activerecord.errors.messages.checked_item.not_available_for_checkout'))
    end

    if item.reserved?
      unless item.manifestation.next_reservation.user == basket.user
        errors.add(:base, I18n.t('activerecord.errors.messages.checked_item.reserved_item_included'))
      end
    end

    checkout_count = basket.user.checked_item_count
    checkout_type = item_checkout_type.checkout_type
    if checkout_count[:"#{checkout_type.name}"] >= item_checkout_type.checkout_limit
      errors.add(:base, I18n.t('activerecord.errors.messages.checked_item.excessed_checkout_limit'))
    end
    
    if errors[:base].empty?
      true
    else
      false
    end
  end

  def item_checkout_type
    if item && basket
      basket.user.profile.user_group.user_group_has_checkout_types.available_for_item(item).first
    end
  end

  def set_due_date
    return nil unless item_checkout_type

    if due_date_string.present?
      date = Time.zone.parse(due_date_string).try(:end_of_day)
    else
      # 返却期限日が閉館日の場合
      if item.shelf.library.closed?(item_checkout_type.checkout_period.days.from_now)
        if item_checkout_type.set_due_date_before_closing_day
          date = (item_checkout_type.checkout_period - 1).days.from_now.end_of_day
        else
          date = (item_checkout_type.checkout_period + 1).days.from_now.end_of_day
        end
      else
        date = (item_checkout_type.checkout_period + 1).days.from_now.end_of_day
      end
    end

    self.due_date = date
    due_date
  end

  def set_item
    identifier = item_identifier.to_s.strip
    if identifier.present?
      item = Item.find_by(item_identifier: identifier)
      self.item = item
    end
  end

  private

  def check_due_date
    return nil unless due_date

    if due_date <= Time.zone.now
      errors.add(:due_date)
    end
  end
end

# == Schema Information
#
# Table name: checked_items
#
#  id           :integer          not null, primary key
#  item_id      :integer          not null
#  basket_id    :integer          not null
#  librarian_id :integer
#  due_date     :datetime         not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  user_id      :integer
#
