FactoryGirl.define do
  factory :carrier_type_has_checkout_type do |f|
    f.carrier_type_id{FactoryGirl.create(:carrier_type).id}
    f.checkout_type_id{FactoryGirl.create(:checkout_type).id}
  end
end
