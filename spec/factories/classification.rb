FactoryGirl.define do
  factory :classification do |f|
    f.sequence(:category){|n| "classification_#{n}"}
    f.classification_type{FactoryGirl.create(:classification_type)}
  end
end
