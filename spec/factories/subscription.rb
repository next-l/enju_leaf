FactoryBot.define do
  factory :subscription do |f|
    f.sequence(:title){|n| "subscription_#{n}"}
    f.user_id{FactoryBot.create(:user).id}
  end
end
