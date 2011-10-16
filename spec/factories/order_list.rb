FactoryGirl.define do
  factory :order_list do |f|
    f.user{FactoryGirl.create(:user)}
    f.sequence(:title){|n| "order_list_#{n}"}
    f.bookstore{FactoryGirl.create(:bookstore)}
  end
end
