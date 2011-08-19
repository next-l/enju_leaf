FactoryGirl.define do
  factory :use_restriction do |f|
    f.sequence(:name){|n| "use_restriction_#{n}"}
  end
end
