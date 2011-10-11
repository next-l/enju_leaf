FactoryGirl.define do
  factory :manifestation_relationship do |f|
    f.parent_id{FactoryGirl.create(:manifestation).id}
    f.child_id{FactoryGirl.create(:manifestation).id}
  end
end
