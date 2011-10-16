FactoryGirl.define do
  factory :exemplify do |f|
    f.manifestation_id{FactoryGirl.create(:manifestation).id}
    f.item_id{FactoryGirl.create(:item).id}
  end
end
