FactoryGirl.define do
  factory :subscription do |f|
    f.sequence(:title){|n| "subscription_#{n}"}
    f.user{FactoryGirl.create(:user)}
  end
end
