Factory.define :checkout_stat_has_user do |f|
  f.user_checkout_stat{Factory(:user_checkout_stat)}
  f.user{Factory(:user)}
end
