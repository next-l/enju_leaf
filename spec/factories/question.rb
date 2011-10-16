FactoryGirl.define do
  factory :question do |f|
    f.sequence(:body){|n| "question_#{n}"}
    f.user_id{FactoryGirl.create(:user).id}
  end
end
