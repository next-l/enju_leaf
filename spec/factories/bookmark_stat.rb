if defined?(BookmarkStat)

FactoryGirl.define do
  factory :bookmark_stat do |f|
    f.start_date 1.week.ago
    f.end_date 1.day.ago
  end
end

end
