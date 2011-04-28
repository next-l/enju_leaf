Factory.define :message_request do |f|
  f.sequence(:sender){Factory(:user)}
  f.sequence(:receiver){Factory(:user)}
  f.sequence(:message_template){Factory(:message_template)}
end
