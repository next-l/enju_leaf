FactoryGirl.define do
  factory :checkout_stat_has_user do |f|
    f.user_checkout_stat{FactoryGirl.create(:user_checkout_stat)}
    f.user{FactoryGirl.create(:user)}
  end
end
