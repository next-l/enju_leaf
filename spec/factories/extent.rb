FactoryGirl.define do
  factory :extent do |f|
    f.sequence(:name){|n| "extent_#{n}"}
  end
end
