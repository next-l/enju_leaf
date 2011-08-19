FactoryGirl.define do
  factory :patron_type do |f|
    f.sequence(:name){|n| "patron_type_#{n}"}
  end
end
