Factory.define :carrier_type_has_checkout_type do |f|
  f.carrier_type{Factory(:carrier_type)}
  f.checkout_type{Factory(:checkout_type)}
end
