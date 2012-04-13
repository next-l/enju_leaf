require 'spec_helper'

describe Accept do
  fixtures :all

  it "should change circulation_status" do
    accept = FactoryGirl.create(:accept)
    accept.item.circulation_status.name.should eq 'Available On Shelf'
  end
end
# == Schema Information
#
# Table name: accepts
#
#  id           :integer         not null, primary key
#  basket_id    :integer
#  item_id      :integer
#  librarian_id :integer
#  created_at   :datetime        not null
#  updated_at   :datetime        not null
#

