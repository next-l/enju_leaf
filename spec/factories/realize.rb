FactoryGirl.define do
  factory :realize do |f|
    f.expression_id{FactoryGirl.create(:manifestation).id}
    f.agent_id{FactoryGirl.create(:agent).id}
  end
end
