FactoryGirl.define do
  factory :bookmark do |f|
    f.sequence(:title){|n| "bookmark_#{n}"}
    f.sequence(:url){|n| "http://example.jp/#{n}"}
    f.user_id{FactoryGirl.create(:user).id}
  end
end
