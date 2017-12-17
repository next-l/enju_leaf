FactoryBot.define do
  factory :manifestation_relationship do |f|
    f.parent_id{FactoryBot.create(:manifestation).id}
    f.child_id{FactoryBot.create(:manifestation).id}
  end
end
