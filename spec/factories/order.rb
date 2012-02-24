FactoryGirl.define do
  factory :order do |f|
    f.order_list_id{FactoryGirl.create(:order_list).id}
    f.purchase_request_id{FactoryGirl.create(:purchase_request).id}
  end
end
