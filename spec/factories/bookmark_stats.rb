FactoryBot.define do
  factory :bookmark_stat do |f|
    f.start_date { 1.week.ago }
    f.end_date { 1.day.ago }
  end
end

# == Schema Information
#
# Table name: bookmark_stats
#
#  id           :bigint           not null, primary key
#  start_date   :datetime
#  end_date     :datetime
#  started_at   :datetime
#  completed_at :datetime
#  note         :text
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
