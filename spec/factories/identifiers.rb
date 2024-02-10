FactoryBot.define do
  factory :identifier do
    sequence(:body){|n| "identifier_body_#{n}"}
    association :identifier_type
    association :manifestation
  end
end

# == Schema Information
#
# Table name: identifiers
#
#  id                 :integer          not null, primary key
#  body               :string           not null
#  identifier_type_id :integer          not null
#  manifestation_id   :integer
#  primary            :boolean
#  position           :integer
#  created_at         :datetime
#  updated_at         :datetime
#
