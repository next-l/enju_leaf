Factory.define :lending_policy do |f|
  f.user_group{Factory(:user_group)}
  f.item{Factory(:item)}
end
