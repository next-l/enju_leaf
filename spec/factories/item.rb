FactoryGirl.define do
  factory :item do |f|
    f.sequence(:item_identifier){|n| "item_#{n}"}
    f.circulation_status{CirculationStatus.find(1)}
  end
end
