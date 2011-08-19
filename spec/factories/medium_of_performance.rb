FactoryGirl.define do
  factory :medium_of_performance do |f|
    f.sequence(:name){|n| "medium_of_performance_#{n}"}
  end
end
