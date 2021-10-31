FactoryBot.define do
  factory :manifestation_custom_property do
    sequence(:name){|n| "property_name_#{n}"}
    sequence(:display_name){|n| "プロパティ名_#{n}"}
  end
end

# == Schema Information
#
# Table name: manifestation_custom_properties
#
#  id           :bigint           not null, primary key
#  name         :string           not null
#  display_name :text             not null
#  note         :text
#  position     :integer          default(1), not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
