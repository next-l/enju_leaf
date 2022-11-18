# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :withdraw do
    item_id{FactoryBot.create(:item).id}
    librarian_id{FactoryBot.create(:librarian).id}
    basket_id{FactoryBot.create(:basket, user_id: librarian_id).id}
  end
end

# == Schema Information
#
# Table name: withdraws
#
#  id           :bigint           not null, primary key
#  basket_id    :bigint
#  item_id      :bigint
#  librarian_id :bigint
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
