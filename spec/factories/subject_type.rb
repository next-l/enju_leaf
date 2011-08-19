FactoryGirl.define do
  factory :subject_type do |f|
    f.sequence(:name){|n| "subject_type_#{n}"}
  end
end
