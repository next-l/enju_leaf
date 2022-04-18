FactoryBot.define do
  factory :bookmark do
    sequence(:title){|n| "bookmark_#{n}"}
    sequence(:url){|n| "http://example.jp/#{n}"}
    user_id{FactoryBot.create(:user).id}
    association :manifestation
  end
end
