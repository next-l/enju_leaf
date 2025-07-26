FactoryBot.define do
  factory :identifier do
    sequence(:body) {|n| "identifier_body_#{n}"}
    association :identifier_type
    association :manifestation
  end
end

# == Schema Information
#
# Table name: identifiers
#
#  id                 :bigint           not null, primary key
#  body               :string           not null
#  position           :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  identifier_type_id :bigint           not null
#  manifestation_id   :bigint
#
# Indexes
#
#  index_identifiers_on_body_and_identifier_type_id  (body,identifier_type_id)
#  index_identifiers_on_manifestation_id             (manifestation_id)
#
