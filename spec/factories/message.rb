Factory.define :message do |f|
  f.recipient {Factory(:user).username}
  f.sender {Factory(:user)}
  f.subject 'new message'
  f.body 'new message body is really short'
end
