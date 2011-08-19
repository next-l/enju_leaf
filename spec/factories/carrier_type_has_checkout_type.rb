FactoryGirl.define do
  factory :carrier_type_has_checkout_type do |f|
    f.carrier_type{FactoryGirl.create(:carrier_type)}
    f.checkout_type{FactoryGirl.create(:checkout_type)}
  end
end
