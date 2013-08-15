FactoryGirl.define do
  factory :agent do |f|
    f.sequence(:full_name){|n| "full_name_#{n}"}
    f.agent_type_id{AgentType.find_by_name('Person').id}
    f.country_id{Country.first.id}
    f.language_id{Language.first.id}
  end
end

FactoryGirl.define do
  factory :invalid_agent, :class => Agent do |f|
  end
end
