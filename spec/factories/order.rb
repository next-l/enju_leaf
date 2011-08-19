FactoryGirl.define do
  factory :order do |f|
    f.order_list{FactoryGirl.create(:order_list)}
    f.purchase_request{FactoryGirl.create(:purchase_request)}
  end
end
