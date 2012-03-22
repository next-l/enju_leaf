require 'spec_helper'

describe Accept do
  fixtures :all

  it "should change circulation_status" do
    accept = FactoryGirl.create(:accept)
    accept.item.circulation_status.name.should eq 'Available On Shelf'
  end
end
