FactoryGirl.define do
  factory :event_category do |f|
    f.sequence(:name){|n| "event_category_#{n}"}
  end
end
