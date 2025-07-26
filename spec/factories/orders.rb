FactoryBot.define do
  factory :order do |f|
    f.order_list_id {FactoryBot.create(:order_list).id}
    f.purchase_request_id {FactoryBot.create(:purchase_request).id}
  end
end

# == Schema Information
#
# Table name: orders
#
#  id                  :bigint           not null, primary key
#  position            :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  order_list_id       :bigint           not null
#  purchase_request_id :bigint           not null
#
# Indexes
#
#  index_orders_on_order_list_id        (order_list_id)
#  index_orders_on_purchase_request_id  (purchase_request_id)
#
# Foreign Keys
#
#  fk_rails_...  (order_list_id => order_lists.id)
#  fk_rails_...  (purchase_request_id => purchase_requests.id)
#
