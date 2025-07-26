FactoryBot.define do
  factory :periodical do
    sequence(:original_title) {|n| "periodical_title_#{n}"}
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
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  frequency_id     :bigint           not null
#  manifestation_id :bigint           not null
#
# Indexes
#
#  index_periodicals_on_frequency_id      (frequency_id)
#  index_periodicals_on_manifestation_id  (manifestation_id)
#
# Foreign Keys
#
#  fk_rails_...  (frequency_id => frequencies.id)
#  fk_rails_...  (manifestation_id => manifestations.id)
#
