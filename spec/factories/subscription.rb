Factory.define :subscription do |f|
  f.sequence(:title){|n| "subscription_#{n}"}
  f.user{Factory(:user)}
end
