FactoryBot.define do
  factory :manifestation_custom_value do
    association :manifestation_custom_property
    sequence(:value) {|n| "value_#{n}"}
  end
end

# == Schema Information
#
# Table name: manifestation_custom_values
#
#  id                               :bigint           not null, primary key
#  value                            :text
#  created_at                       :datetime         not null
#  updated_at                       :datetime         not null
#  manifestation_custom_property_id :bigint           not null
#  manifestation_id                 :bigint           not null
#
# Indexes
#
#  index_manifestation_custom_values_on_custom_property_id      (manifestation_custom_property_id)
#  index_manifestation_custom_values_on_manifestation_id        (manifestation_id)
#  index_manifestation_custom_values_on_property_manifestation  (manifestation_custom_property_id,manifestation_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (manifestation_custom_property_id => manifestation_custom_properties.id)
#  fk_rails_...  (manifestation_id => manifestations.id)
#
