FactoryBot.define do
  factory :create do |f|
    f.work_id{FactoryBot.create(:manifestation).id}
    f.agent_id{FactoryBot.create(:agent).id}
  end
end
