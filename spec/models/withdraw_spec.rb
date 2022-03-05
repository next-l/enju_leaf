require 'rails_helper'

RSpec.describe Withdraw, type: :model do
  fixtures :all

  it "should change circulation_status" do
    withdraw = FactoryBot.create(:withdraw)
    withdraw.item.circulation_status.name.should eq 'Removed'
    withdraw.item.use_restriction.name.should eq 'Not For Loan'
  end

  it "should not withdraw rented item" do
    withdraw = Withdraw.new(librarian: users(:librarian1))
    withdraw.item = items(:item_00013)
    withdraw.valid?.should be_falsy
  end
end

# == Schema Information
#
# Table name: withdraws
#
#  id           :integer          not null, primary key
#  basket_id    :integer
#  item_id      :integer
#  librarian_id :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
