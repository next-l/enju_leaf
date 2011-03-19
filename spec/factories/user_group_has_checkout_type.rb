Factory.define :user_group_has_checkout_type do |f|
  f.subject_heading_type{Factory(:user_group)}
  f.subject{Factory(:checkout_type)}
end
