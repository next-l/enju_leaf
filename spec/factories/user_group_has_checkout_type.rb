FactoryGirl.define do
  factory :user_group_has_checkout_type do |f|
    f.user_group_id{FactoryGirl.create(:user_group).id}
    f.checkout_type_id{FactoryGirl.create(:checkout_type).id}
  end
end
