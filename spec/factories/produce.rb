FactoryGirl.define do
  factory :produce do |f|
    f.manifestation_id{FactoryGirl.create(:manifestation).id}
    f.agent_id{FactoryGirl.create(:agent).id}
  end
end
