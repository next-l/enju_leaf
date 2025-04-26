require 'rails_helper'

describe Checkin do
  fixtures :all

  before(:each) do
    @basket = Basket.new
    @basket.user = users(:librarian1)
    @basket.save
  end

  it "should save checkout history if save_checkout_history is true" do
    user = users(:user1)
    checkouts_count = user.checkouts.count
    checkin = Checkin.new
    checkin.item = user.checkouts.not_returned.first.item
    checkin.basket = @basket
    checkin.librarian = users(:librarian1)
    # checkin.item_identifier = checkin.item.item_identifier
    checkin.save!
    checkin.item_checkin(user)
    expect(user.checkouts.count).to eq checkouts_count
  end

  it "should not save checkout history if save_checkout_history is false" do
    user = users(:librarian1)
    checkouts_count = user.checkouts.count
    checkin = Checkin.new
    checkin.item = user.checkouts.not_returned.first.item
    checkin.basket = @basket
    checkin.librarian = users(:librarian1)
    checkin.save!
    checkin.item_checkin(user)
    expect(user.checkouts.count).to eq checkouts_count - 1
  end
end

# == Schema Information
#
# Table name: checkins
#
#  id           :bigint           not null, primary key
#  lock_version :integer          default(0), not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  basket_id    :bigint
#  item_id      :bigint           not null
#  librarian_id :bigint
#
# Indexes
#
#  index_checkins_on_basket_id              (basket_id)
#  index_checkins_on_item_id_and_basket_id  (item_id,basket_id) UNIQUE
#  index_checkins_on_librarian_id           (librarian_id)
#
# Foreign Keys
#
#  fk_rails_...  (item_id => items.id)
#
