FactoryGirl.define do
  factory :create do |f|
    f.work_id{FactoryGirl.create(:manifestation).id}
    f.agent_id{FactoryGirl.create(:agent).id}
  end
end
