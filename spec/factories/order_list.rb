Factory.define :order_list do |f|
  f.user{Factory(:user)}
  f.sequence(:title){|n| "order_list_#{n}"}
  f.bookstore{Factory(:bookstore)}
end
