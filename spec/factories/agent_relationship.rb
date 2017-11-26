FactoryBot.define do
  factory :agent_relationship do |f|
    f.parent_id{FactoryBot.create(:agent).id}
    f.child_id{FactoryBot.create(:agent).id}
  end
end
