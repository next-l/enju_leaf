# -*- encoding: utf-8 -*-
require 'spec_helper'

describe Reserve do
  fixtures :all

  it "should have next reservation" do
    reserves(:reserve_00001).next_reservation.should be_true
  end

  it "should expire reservation" do
    reserves(:reserve_00001).expire
    reserves(:reserve_00001).request_status_type.name.should eq 'Expired'
  end

  it "should cancel reservation" do
    reserves(:reserve_00001).cancel
    reserves(:reserve_00001).canceled_at.should be_true
    reserves(:reserve_00001).request_status_type.name.should eq 'Cannot Fulfill Request'
  end

  it "should not have next reservation" do
    reserves(:reserve_00002).next_reservation.should be_nil
  end

  it "should send accepted message" do
    old_admin_count = User.find('admin').received_messages.count
    old_user_count = reserves(:reserve_00002).user.received_messages.count
    reserves(:reserve_00002).send_message('accepted').should be_true
    # 予約者と図書館の両方に送られる
    User.find('admin').received_messages.count.should eq old_admin_count + 1
    reserves(:reserve_00002).user.received_messages.count.should eq old_user_count + 1
  end

  it "should send expired message" do
    old_count = MessageRequest.count
    reserves(:reserve_00002).send_message('expired').should be_true
    MessageRequest.count.should eq old_count + 1
  end

  it "should send message to library" do
    Reserve.send_message_to_library('expired', :manifestations => Reserve.not_sent_expiration_notice_to_library.collect(&:manifestation)).should be_true
  end

  it "should have reservations that will be expired" do
    Reserve.will_expire_retained(Time.zone.now).size.should eq 1
  end

  it "should have completed reservation" do
    Reserve.completed.size.should eq 1
  end

  it "should expire all reservations" do
    assert Reserve.expire.should be_true
  end
end

# == Schema Information
#
# Table name: reserves
#
#  id                           :integer         not null, primary key
#  user_id                      :integer         not null
#  manifestation_id             :integer         not null
#  item_id                      :integer
#  request_status_type_id       :integer         not null
#  checked_out_at               :datetime
#  created_at                   :datetime
#  updated_at                   :datetime
#  canceled_at                  :datetime
#  expired_at                   :datetime
#  deleted_at                   :datetime
#  state                        :string(255)
#  expiration_notice_to_patron  :boolean         default(FALSE)
#  expiration_notice_to_library :boolean         default(FALSE)
#

