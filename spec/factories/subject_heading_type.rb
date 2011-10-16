FactoryGirl.define do
  factory :subject_heading_type do |f|
    f.sequence(:name){|n| "subject_heading_type_#{n}"}
  end
end
