FactoryGirl.define do
  factory :item do |f|
    f.sequence(:item_identifier){|n| "item_#{n}"}
    f.circulation_status_id{CirculationStatus.find(1).id}
    f.manifestation_id{FactoryGirl.create(:manifestation).id}
  end
end
