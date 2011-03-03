Factory.define :reserve_stat_has_user do |f|
  f.user_reserve_stat{Factory(:user_reserve_stat)}
  f.user{Factory(:user)}
end
