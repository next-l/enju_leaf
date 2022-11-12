FactoryBot.define do
  factory :identifier do
    sequence(:body){|n| "identifier_body_#{n}"}
    identifier_type_id{FactoryBot.create(:identifier_type).id}
    association(:manifestation)
  end
end

# == Schema Information
#
# Table name: identifiers
#
#  id                 :bigint           not null, primary key
#  body               :string           not null
#  identifier_type_id :integer          not null
#  manifestation_id   :bigint
#  primary            :boolean
#  position           :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
