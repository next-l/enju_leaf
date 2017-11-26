FactoryBot.define do
  factory :produce do |f|
    f.manifestation_id{FactoryBot.create(:manifestation).id}
    f.agent_id{FactoryBot.create(:agent).id}
  end
end
