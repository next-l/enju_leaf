FactoryGirl.define do
  factory :classification_type do |f|
    f.sequence(:name){|n| "classification_type_#{n}"}
  end
end
