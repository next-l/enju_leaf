FactoryBot.define do
  factory :order_list do |f|
    f.user_id{FactoryBot.create(:user).id}
    f.sequence(:title){|n| "order_list_#{n}"}
    f.bookstore_id{FactoryBot.create(:bookstore).id}
  end
end
