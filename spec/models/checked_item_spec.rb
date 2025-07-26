require 'rails_helper'

describe CheckedItem do
  fixtures :all

  it "should respond to available_for_checkout?" do
    checked_items(:checked_item_00001).available_for_checkout?.should_not be_truthy
  end

  it "should change circulation_status when a missing item is found" do
    basket = Basket.new
    basket.user = users(:admin)
    checked_item = CheckedItem.new
    checked_item.item = items(:item_00024)
    checked_item.basket = basket
    checked_item.save!
    items(:item_00024).circulation_status.name.should eq 'Available On Shelf'
  end

  it "should checkout an item that its reservation is expired" do
    item = items(:item_00024)
    reserve = FactoryBot.create(:reserve, manifestation: item.manifestation)
    reserve.transition_to!(:expired)
    checked_item = CheckedItem.new
    checked_item.item = item
    checked_item.basket = Basket.new(user: users(:admin))
    expect(checked_item.save).to be_truthy
  end
end

# == Schema Information
#
# Table name: checked_items
#
#  id           :bigint           not null, primary key
#  due_date     :datetime         not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  basket_id    :bigint           not null
#  item_id      :bigint           not null
#  librarian_id :bigint
#  user_id      :bigint
#
# Indexes
#
#  index_checked_items_on_basket_id              (basket_id)
#  index_checked_items_on_item_id_and_basket_id  (item_id,basket_id) UNIQUE
#  index_checked_items_on_librarian_id           (librarian_id)
#  index_checked_items_on_user_id                (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (basket_id => baskets.id)
#  fk_rails_...  (item_id => items.id)
#  fk_rails_...  (user_id => users.id)
#
