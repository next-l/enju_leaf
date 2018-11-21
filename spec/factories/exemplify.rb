FactoryBot.define do
  factory :exemplify do |f|
    f.manifestation_id{FactoryBot.create(:manifestation).id}
    f.item_id{FactoryBot.create(:item).id}
  end
end
