FactoryBot.define do
  factory :agent_type do |f|
    f.sequence(:name){|n| "agent_type_#{n}"}
  end
end
