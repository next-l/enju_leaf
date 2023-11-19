FactoryBot.define do
  factory :doi_record do
    sequence(:body){|n| "body_#{n}"}
    association :manifestation
  end
end

# == Schema Information
#
# Table name: doi_records
#
#  id               :bigint           not null, primary key
#  body             :string           not null
#  manifestation_id :bigint           not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
