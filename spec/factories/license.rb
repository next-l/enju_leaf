FactoryGirl.define do
  factory :license do |f|
    f.sequence(:name){|n| "license_#{n}"}
  end
end
