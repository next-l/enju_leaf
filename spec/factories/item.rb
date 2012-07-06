FactoryGirl.define do
  factory :item, :class => Item do |f|
    f.shelf_id{Shelf.find(2).id}
    f.sequence(:item_identifier){|n| "item_#{n}"}
    #f.circulation_status_id{CirculationStatus.find(1).id} if defined?(EnjuCircuation)
    f.circulation_status_id{CirculationStatus.find(2).id}
    f.manifestation{FactoryGirl.create(:manifestation)}
  end

  factory :item_item_identifier_is_null, :class => Item do |f|
    f.shelf_id{Shelf.find(2).id}
    f.sequence(:item_identifier){|n| "item_#{n}"}
    f.circulation_status_id{CirculationStatus.find(2).id}
    f.manifestation{FactoryGirl.create(:manifestation)}
  end

  factory :item_book, :class => Item do |f|
    f.sequence(:item_identifier){|n| "book_#{n}"}
    f.circulation_status_id{CirculationStatus.find(2).id}
    f.manifestation{FactoryGirl.create(:manifestation)}
    f.checkout_type{CheckoutType.find_by_name('book')}
  end

  factory :item_serial, :class => Item do |f|
    f.sequence(:item_identifier){|n| "serial_#{n}"}
    f.circulation_status_id{CirculationStatus.find(2).id}
    f.manifestation{FactoryGirl.create(:manifestation)}
    f.checkout_type{CheckoutType.find_by_name('serial')}
  end

  factory :item_cd, :class => Item do |f|
    f.sequence(:item_identifier){|n| "cd_#{n}"}
    f.circulation_status_id{CirculationStatus.find(2).id}
    f.manifestation{FactoryGirl.create(:manifestation)}
    f.checkout_type{CheckoutType.find_by_name('cd')}
  end
  
  factory :missing_item, :class => Item do |f|
    f.sequence(:item_identifier){|n| "missing_#{n}"}
    f.circulation_status_id{CirculationStatus.find(3).id}
    f.manifestation{FactoryGirl.create(:manifestation)}
    f.checkout_type{CheckoutType.find_by_name('book')}
  end
end
