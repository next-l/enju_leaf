FactoryBot.define do
  factory :order do |f|
    f.order_list_id{FactoryBot.create(:order_list).id}
    f.purchase_request_id{FactoryBot.create(:purchase_request).id}
  end
end

# == Schema Information
#
# Table name: orders
#
#  id                  :bigint           not null, primary key
#  order_list_id       :bigint           not null
#  purchase_request_id :bigint           not null
#  position            :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
