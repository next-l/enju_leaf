FactoryGirl.define do
  factory :request_status_type do |f|
    f.sequence(:name){|n| "request_status_type_#{n}"}
  end
end
