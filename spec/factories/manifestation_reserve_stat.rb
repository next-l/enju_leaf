FactoryGirl.define do
  factory :manifestation_reserve_stat do |f|
    f.start_date 1.week.ago
    f.end_date 1.day.ago
  end
end
