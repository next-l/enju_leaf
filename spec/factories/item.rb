Factory.define :item do |f|
  f.manifestation{Factory(:manifestation)}
  f.sequence(:item_identifier){|n| "item_#{n}"}
  f.circulation_status{CirculationStatus.find(1)}
end
