FactoryGirl.define do
  factory :answer do |f|
    f.sequence(:body){|n| "answer_#{n}"}
    f.sequence(:question){FactoryGirl.create(:question_libraryA)}
    f.sequence(:user){FactoryGirl.create(:user)}
  end
end
