FactoryGirl.define do
  factory :lending_policy do |f|
    f.user_group{FactoryGirl.create(:user_group)}
    f.item{FactoryGirl.create(:item)}
  end
end
