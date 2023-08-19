FactoryBot.define do
  factory :order do |f|
    f.order_list_id{FactoryBot.create(:order_list).id}
    f.purchase_request_id{FactoryBot.create(:purchase_request).id}
  end
end
