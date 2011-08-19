FactoryGirl.define do
  factory :subject do |f|
    f.sequence(:term){|n| "subject_#{n}"}
    f.subject_type{FactoryGirl.create(:subject_type)}
  end
end
