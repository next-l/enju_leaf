FactoryGirl.define do
  factory :subscription do |f|
    f.sequence(:title){|n| "subscription_#{n}"}
    f.user_id{FactoryGirl.create(:user).id}
  end
end
