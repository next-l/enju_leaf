FactoryBot.define do
  factory :news_feed do |f|
    f.sequence(:title){|n| "news_feed_#{n}"}
    f.sequence(:url){|n| "http://www.example.com/feed/#{n}"}
  end
end
