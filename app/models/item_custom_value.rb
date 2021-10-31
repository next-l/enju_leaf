class ItemCustomValue < ApplicationRecord
  belongs_to :item_custom_property
  belongs_to :item, optional: true
  validates :item_custom_property, uniqueness: {scope: :item_id}
end

# == Schema Information
#
# Table name: item_custom_values
#
#  id                      :bigint           not null, primary key
#  item_custom_property_id :bigint           not null
#  item_id                 :bigint           not null
#  value                   :text
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#
