Factory.define :manifestation do |f|
  f.sequence(:original_title){|n| "manifestation_title_#{n}"}
  f.carrier_type{CarrierType.find(1)}
end
