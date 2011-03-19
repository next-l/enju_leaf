Factory.define :carrier_type do |f|
  f.sequence(:name){|n| "carrier_type_#{n}"}
end
