FactoryGirl.define do
  factory :reserve_stat_has_user do |f|
    f.user_reserve_stat{FactoryGirl.create(:user_reserve_stat)}
    f.user{FactoryGirl.create(:user)}
  end
end
