FactoryGirl.define do
  factory :question_libraryA, :class => 'Question' do |f|
    f.sequence(:body){|n| "question_LibraryA_#{n}"}
    f.user { FactoryGirl.create(:adult_user) }
  end
  factory :question_libraryB, :class => 'Question' do |f|
    f.sequence(:body){|n| "question_LibraryB_#{n}"}
    f.user { FactoryGirl.create(:juniors_user) }
  end
end
