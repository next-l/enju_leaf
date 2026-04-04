FactoryBot.define do
  factory :agent_merge_list do |f|
    f.sequence(:title) { |n| "agent_merge_list_#{n}" }
  end
end
