FactoryGirl.define do
  factory :request_type do |f|
    f.sequence(:name){|n| "request_type_#{n}"}
  end
end
