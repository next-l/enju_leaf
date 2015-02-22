FactoryGirl.define do
  factory :donate do |f|
    f.item_id{FactoryGirl.create(:item).id}
    f.agent_id{FactoryGirl.create(:agent).id}
  end
end
