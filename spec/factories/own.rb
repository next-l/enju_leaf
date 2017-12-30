FactoryBot.define do
  factory :own do |f|
    f.item_id{FactoryBot.create(:item).id}
    f.agent_id{FactoryBot.create(:agent).id}
  end
end
