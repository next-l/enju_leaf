FactoryBot.define do
  factory :manifestation_custom_value do
    association :manifestation_custom_property
    sequence(:value){|n| "value_#{n}"}
  end
end

# == Schema Information
#
# Table name: manifestation_custom_values
#
#  id                               :bigint           not null, primary key
#  manifestation_custom_property_id :bigint           not null
#  manifestation_id                 :bigint           not null
#  value                            :text
#  created_at                       :datetime         not null
#  updated_at                       :datetime         not null
#
