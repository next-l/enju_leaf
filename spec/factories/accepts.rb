# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :accept do
    basket_id {FactoryBot.create(:basket).id}
    item_id {FactoryBot.create(:item).id}
    librarian_id {FactoryBot.create(:librarian).id}
  end
end

# == Schema Information
#
# Table name: accepts
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
#  index_accepts_on_basket_id     (basket_id)
#  index_accepts_on_item_id       (item_id) UNIQUE
#  index_accepts_on_librarian_id  (librarian_id)
#
