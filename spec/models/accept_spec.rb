require 'rails_helper'

describe Accept do
  fixtures :all

  it "should change circulation_status" do
    accept = FactoryBot.create(:accept)
    accept.item.circulation_status.name.should eq 'Available On Shelf'
    accept.item.use_restriction.name.should eq 'Limited Circulation, Normal Loan Period'
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
