Factory.define :user_group_has_checkout_type do |f|
  f.user_group{Factory(:user_group)}
  f.checkout_type{Factory(:checkout_type)}
end
