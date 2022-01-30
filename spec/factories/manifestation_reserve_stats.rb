FactoryBot.define do
  factory :manifestation_reserve_stat do
    start_date { 1.week.ago }
    end_date { 1.day.ago }
    association :user, factory: :librarian
  end
end

# == Schema Information
#
# Table name: manifestation_reserve_stats
#
#  id           :integer          not null, primary key
#  start_date   :datetime
#  end_date     :datetime
#  note         :text
#  created_at   :datetime
#  updated_at   :datetime
#  started_at   :datetime
#  completed_at :datetime
#  user_id      :integer
#