FactoryBot.define do
  factory :agent do |f|
    f.sequence(:full_name){|n| "full_name_#{n}"}
    f.agent_type_id{AgentType.find_by(name: 'Person').id}
    f.country_id{Country.first.id}
    f.language_id{Language.first.id}
  end
end

FactoryBot.define do
  factory :invalid_agent, class: Agent do |f|
  end
end
