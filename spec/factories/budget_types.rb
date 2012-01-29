FactoryGirl.define do
  factory :budget_type do |f|
    f.sequence(:name){|n| "budget_type_#{n}"}
  end
end
