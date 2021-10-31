FactoryBot.define do
  factory :item_custom_value do
    association :item_custom_property
    sequence(:value){|n| "value_#{n}"}
  end
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
