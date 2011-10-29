FactoryGirl.define do
  factory :answer do |f|
    f.sequence(:body){|n| "answer_#{n}"}
    f.question_id{FactoryGirl.create(:question).id}
    f.user_id{FactoryGirl.create(:user).id}
  end
end
