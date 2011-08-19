FactoryGirl.define do
  factory :frequency do |f|
    f.sequence(:name){|n| "frequency_#{n}"}
  end
end
