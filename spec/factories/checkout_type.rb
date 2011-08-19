FactoryGirl.define do
  factory :checkout_type do |f|
    f.sequence(:name){|n| "checkout_type_#{n}"}
  end
end
