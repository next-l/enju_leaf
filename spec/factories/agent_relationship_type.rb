FactoryGirl.define do
  factory :agent_relationship_type do |f|
    f.sequence(:name){|n| "agent_relationship_type_#{n}"}
  end
end
