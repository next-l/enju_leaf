FactoryGirl.define do
  factory :agent_relationship do |f|
    f.parent_id{FactoryGirl.create(:agent).id}
    f.child_id{FactoryGirl.create(:agent).id}
  end
end
