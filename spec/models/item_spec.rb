# -*- encoding: utf-8 -*-
require 'spec_helper'

describe Item do
  #pending "add some examples to (or delete) #{__FILE__}"
  fixtures :all

  it "should be rent" do
    items(:item_00001).rent?.should be_true
  end

  it "should not be rent" do
    items(:item_00010).rent?.should be_false
  end

  it "should be checked out" do
    items(:item_00010).checkout!(users(:admin)).should be_true
    items(:item_00010).circulation_status.name.should eq 'On Loan'
  end

  it "should be checked in" do
    items(:item_00001).checkin!.should be_true
    items(:item_00001).circulation_status.name.should eq 'Available On Shelf'
  end

  it "should be retained" do
    old_count = MessageRequest.count
    items(:item_00022).retain(users(:librarian1)).should be_true
    MessageRequest.count.should eq old_count + 1
  end

  it "should not be checked out when it is clamed" do
    items(:item_00012).available_for_checkout?.should be_false
  end

  it "should have library_url" do
    items(:item_00001).library_url.should eq "#{LibraryGroup.site_config.url}libraries/web"
  end

  it "should not set next reserve when next reservation is blank" do
    items(:item_00028).set_next_reservation.should be_false
  end

  it "should set retained when receipt library of next reservation equal library of item" do
    items(:item_00027).set_next_reservation
    reserves(:reserve_00021).state.should eq 'retained'
  end

  it "should set in_process when receipt library of next reservation not equal library of item" do
    items(:item_00029).set_next_reservation
    reserves(:reserve_00024).state.should eq 'in_process'
  end

  it "should revert requested when item that is not retained  was check out" do
    items(:item_00029).checkout!(users(:admin)).should be_true
    reserves(:reserve_00023).state.should eq 'requested'
  end
end

# == Schema Information
#
# Table name: items
#
#  id                          :integer         not null, primary key
#  call_number                 :string(255)
#  item_identifier             :string(255)
#  circulation_status_id       :integer         not null
#  checkout_type_id            :integer         default(1), not null
#  created_at                  :datetime
#  updated_at                  :datetime
#  deleted_at                  :datetime
#  shelf_id                    :integer         default(1), not null
#  include_supplements         :boolean         default(FALSE), not null
#  checkouts_count             :integer         default(0), not null
#  owns_count                  :integer         default(0), not null
#  resource_has_subjects_count :integer         default(0), not null
#  note                        :text
#  url                         :string(255)
#  price                       :integer
#  lock_version                :integer         default(0), not null
#  required_role_id            :integer         default(1), not null
#  state                       :string(255)
#  required_score              :integer         default(0), not null
#  acquired_at                 :datetime
#  bookstore_id                :integer
#

