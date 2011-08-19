FactoryGirl.define do
  factory :content_type do |f|
    f.sequence(:name){|n| "content_type_#{n}"}
  end
end
