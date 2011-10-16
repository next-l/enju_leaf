FactoryGirl.define do
  factory :order_list do |f|
    f.user_id{FactoryGirl.create(:user).id}
    f.sequence(:title){|n| "order_list_#{n}"}
    f.bookstore_id{FactoryGirl.create(:bookstore).id}
  end
end
