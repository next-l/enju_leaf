# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :withdraw do
    item_id {FactoryBot.create(:item).id}
    librarian_id {FactoryBot.create(:librarian).id}
    basket_id {FactoryBot.create(:basket, user_id: librarian_id).id}
  end
end

# == Schema Information
#
# Table name: withdraws
#
#  id           :bigint           not null, primary key
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  basket_id    :bigint
#  item_id      :bigint
#  librarian_id :bigint
#
# Indexes
#
#  index_withdraws_on_basket_id     (basket_id)
#  index_withdraws_on_item_id       (item_id) UNIQUE
#  index_withdraws_on_librarian_id  (librarian_id)
#
