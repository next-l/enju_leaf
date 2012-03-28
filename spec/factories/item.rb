FactoryGirl.define do
  factory :item, :class => Item do |f|
    f.shelf_id{Shelf.find(2).id}
    f.sequence(:item_identifier){|n| "item_#{n}"}
    #f.circulation_status_id{CirculationStatus.find(1).id} if defined?(EnjuCircuation)
    f.circulation_status_id{CirculationStatus.find(2).id}
    f.manifestation_id{FactoryGirl.create(:manifestation).id}
  end

  factory :item_item_identifier_is_null, :class => Item do |f|
    f.shelf_id{Shelf.find(2).id}
    f.sequence(:item_identifier){|n| "item_#{n}"}
    f.circulation_status_id{CirculationStatus.find(2).id}
    f.manifestation_id{FactoryGirl.create(:manifestation).id}
  end
end
