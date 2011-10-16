FactoryGirl.define do
  factory :question do |f|
    f.sequence(:body){|n| "question_#{n}"}
    f.sequence(:user){FactoryGirl.create(:user)}
  end
end
