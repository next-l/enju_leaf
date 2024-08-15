require 'rails_helper'

describe Basket do
  fixtures :all

  it "should not create basket when user is not active" do
    Basket.create(user: users(:user4)).id.should be_nil
  end

  it "should save shelf and library" do
    items(:item_00011).checkouts.count.should eq 0
    basket_1 = Basket.new
    basket_1.user = users(:admin)
    basket_1.save
    checked_item_1 = basket_1.checked_items.new
    checked_item_1.item = items(:item_00011)
    checked_item_1.save
    basket_1.basket_checkout(users(:librarian1))
    items(:item_00011).checkouts.order('id DESC').first.shelf.name.should eq items(:item_00001).shelf.name
    items(:item_00011).checkouts.order('id DESC').first.library.name.should eq users(:librarian1).profile.library.name
  end

  it "should not check out items that are already checked out" do
    items(:item_00011).checkouts.count.should eq 0
    basket_1 = Basket.new
    basket_1.user = users(:admin)
    basket_1.save
    checked_item_1 = basket_1.checked_items.new
    checked_item_1.item = items(:item_00011)
    checked_item_1.save
    basket_2 = Basket.new
    basket_2.user = users(:user1)
    basket_2.save
    checked_item_2 = basket_2.checked_items.new
    checked_item_2.item = items(:item_00011)
    checked_item_2.save
    basket_1.basket_checkout(users(:librarian1))
    lambda{basket_2.basket_checkout(users(:librarian1))}.should raise_exception ActiveRecord::RecordInvalid
    items(:item_00011).checkouts.order('id DESC').first.user.should eq users(:admin)
  end

  it "should change reservation status" do
    basket = Basket.new
    basket.user = users(:librarian2)
    basket.save
    checked_item = basket.checked_items.new
    checked_item.item = items(:item_00023)
    checked_item.save
    checked_item.item.circulation_status.name.should eq 'Available On Shelf'
    basket.basket_checkout(users(:librarian1))
    checked_item.item.circulation_status.name.should eq 'On Loan'
  end

  it "should checkout retained item" do
    checkout = users(:user1).checkouts.order(:created_at).first
    reserve = users(:user2).reserves.create!(manifestation: checkout.item.manifestation)
    basket1 = Basket.new(user: users(:librarian1))
    checkin = Checkin.create!(basket: basket1, librarian: users(:librarian1), item: checkout.item)
    checkin.item_checkin(checkin.librarian)
    basket2 = Basket.create!(user: users(:user2))
    basket2.checked_items.create(item: checkout.item)
    basket2.basket_checkout(basket2.user)
    expect(checkout.item.circulation_status.name).to eq 'On Loan'
    expect(checkout.item.manifestation.reserves.order(created_at: :desc).first.current_state).to eq 'completed'
  end
end

# == Schema Information
#
# Table name: baskets
#
#  id           :bigint           not null, primary key
#  user_id      :bigint
#  note         :text
#  lock_version :integer          default(0), not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
