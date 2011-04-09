Factory.define :answer do |f|
  f.sequence(:body){|n| "answer_#{n}"}
  f.sequence(:question){Factory(:question)}
  f.sequence(:user){Factory(:user)}
end
