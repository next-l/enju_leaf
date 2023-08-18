FactoryBot.define do
  factory :periodical do
    sequence(:original_title){|n| "periodical_title_#{n}"}
    association :manifestation
    frequency_id { 1 }
  end
end

# == Schema Information
#
# Table name: periodicals
#
#  id               :bigint           not null, primary key
#  original_title   :text             not null
#  manifestation_id :bigint           not null
#  frequency_id     :bigint           not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
