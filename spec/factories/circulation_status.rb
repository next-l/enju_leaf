FactoryGirl.define do
  factory :circulation_status do |f|
    f.sequence(:name){|n| "circulation_status_#{n}"}
  end
end
