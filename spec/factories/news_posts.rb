FactoryBot.define do
  factory :news_post do |f|
    f.sequence(:title){|n| "news_post_#{n}"}
    f.sequence(:body){|n| "news_post_#{n}"}
    f.user{FactoryBot.create(:librarian)}
  end
end
