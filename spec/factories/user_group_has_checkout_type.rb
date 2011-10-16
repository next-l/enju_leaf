FactoryGirl.define do
  factory :user_group_has_checkout_type do |f|
    f.user_group{FactoryGirl.create(:user_group)}
    f.checkout_type{FactoryGirl.create(:checkout_type)}
  end
end
