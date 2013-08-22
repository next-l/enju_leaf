if defined?(Bookmark)

FactoryGirl.define do
  factory :bookmark do |f|
    f.sequence(:title){|n| "bookmark_#{n}"}
    f.sequence(:url){|n| "http://example.jp/#{n}"}
    f.user{FactoryGirl.create(:user)}
  end
end

end
