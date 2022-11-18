require 'rails_helper'

RSpec.describe Withdraw, type: :model do
  fixtures :all

  it "should change circulation_status" do
    withdraw = FactoryBot.create(:withdraw)
    expect(withdraw.item.circulation_status.name).to eq 'Removed'
    expect(withdraw.item.use_restriction.name).to eq 'Not For Loan'
  end

  it "should not withdraw rented item" do
    withdraw = Withdraw.new(librarian: users(:librarian1))
    withdraw.item = items(:item_00013)
    expect(withdraw.valid?).to be_falsy
    expect(withdraw.errors.messages[:item_id]).to include('is rented.')
  end

  it "should not withdraw reserved item" do
    reserve = FactoryBot.create(:reserve)
    withdraw = FactoryBot.build(:withdraw, item: reserve.manifestation.items.first)
    expect(withdraw.valid?).to be_falsy
    expect(withdraw.errors.messages[:item_id]).to include('is reserved.')
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
