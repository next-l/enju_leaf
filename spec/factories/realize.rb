FactoryBot.define do
  factory :realize do |f|
    f.expression_id{FactoryBot.create(:manifestation).id}
    f.agent_id{FactoryBot.create(:agent).id}
  end
end
