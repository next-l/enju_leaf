FactoryGirl.define do
  factory :question_libraryA, :class => 'Question' do |f|
    f.sequence(:body){|n| "question_LibraryA_#{n}"}
    f.user {User.where(:library_id => 1, :username => "adult_1").first}
  end
  factory :question_libraryB, :class => 'Question' do |f|
    f.sequence(:body){|n| "question_LibraryB_#{n}"}
    f.user {User.where(:library_id => 2, :username => "juniors_1").first}
  end
end
