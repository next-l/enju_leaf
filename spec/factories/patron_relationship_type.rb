FactoryGirl.define do
  factory :patron_relationship_type do |f|
    f.sequence(:name){|n| "patron_relationship_type_#{n}"}
  end
end
