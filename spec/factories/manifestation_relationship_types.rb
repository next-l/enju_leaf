FactoryBot.define do
  factory :manifestation_relationship_type do
    sequence(:name){|n| "manifestation_relationship_type_#{n}"}
  end
end

# == Schema Information
#
# Table name: manifestation_relationship_types
#
#  id           :integer          not null, primary key
#  name         :string           not null
#  display_name :text
#  note         :text
#  position     :integer
#  created_at   :datetime
#  updated_at   :datetime
#