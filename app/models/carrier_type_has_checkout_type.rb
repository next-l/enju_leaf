class CarrierTypeHasCheckoutType < ApplicationRecord
  scope :available_for_carrier_type, lambda {|carrier_type| includes(:carrier_type).where('carrier_types.name = ?', carrier_type.name)}
  scope :available_for_user_group, lambda {|user_group| includes(checkout_type: :user_groups).where('user_groups.name = ?', user_group.name)}

  belongs_to :carrier_type
  belongs_to :checkout_type

  validates :checkout_type_id, uniqueness: { scope: :carrier_type_id }

  acts_as_list scope: :carrier_type_id
end

# == Schema Information
#
# Table name: carrier_type_has_checkout_types
#
#  id               :bigint           not null, primary key
#  carrier_type_id  :integer          not null
#  checkout_type_id :integer          not null
#  note             :text
#  position         :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
