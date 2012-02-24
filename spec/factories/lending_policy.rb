FactoryGirl.define do
  factory :lending_policy do |f|
    f.user_group_id{FactoryGirl.create(:user_group).id}
    f.item_id{FactoryGirl.create(:item).id}
  end
end
