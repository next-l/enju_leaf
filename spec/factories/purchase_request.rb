Factory.define :purchase_request do |f|
  f.sequence(:title){|n| "purchase_request_#{n}"}
  f.user{Factory(:user)}
end
