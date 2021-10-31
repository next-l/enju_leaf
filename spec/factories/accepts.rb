# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :accept do
    basket_id{FactoryBot.create(:basket).id}
    item_id{FactoryBot.create(:item).id}
    librarian_id{FactoryBot.create(:librarian).id}
  end
end

# == Schema Information
#
# Table name: accepts
#
#  id           :integer          not null, primary key
#  basket_id    :integer
#  item_id      :integer
#  librarian_id :integer
#  created_at   :datetime
#  updated_at   :datetime
#
