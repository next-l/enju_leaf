Factory.define :question do |f|
  f.sequence(:body){|n| "question_#{n}"}
  f.sequence(:user){Factory(:user)}
end
