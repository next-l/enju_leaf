require 'rails_helper'

describe Reserve do
  fixtures :all

  it "should have next reservation" do
    expect(reserves(:reserve_00014).state_machine.current_state).to eq "retained"
    expect(reserves(:reserve_00014).next_reservation).to eq reserves(:reserve_00015)
    reserves(:reserve_00014).transition_to!(:canceled)
    expect(reserves(:reserve_00015).state_machine.current_state).to eq "retained"
    expect(reserves(:reserve_00015).next_reservation).to eq reserves(:reserve_00016)
  end

  it "should notify a next reservation" do
    old_count = Message.count
    reserve = reserves(:reserve_00014)
    item = reserve.item
    reserve.transition_to!(:expired)
    expect(reserve.current_state).to eq 'expired'
    expect(item).to eq reserve.next_reservation.item
    Message.count.should eq old_count + 4
  end

  it "should expire reservation" do
    reserves(:reserve_00001).transition_to!(:expired)
    reserves(:reserve_00001).request_status_type.name.should eq 'Expired'
  end

  it "should cancel reservation" do
    reserves(:reserve_00001).transition_to!(:canceled)
    reserves(:reserve_00001).canceled_at.should be_truthy
    reserves(:reserve_00001).request_status_type.name.should eq 'Cannot Fulfill Request'
  end

  it "should not have next reservation" do
    reserves(:reserve_00002).next_reservation.should be_nil
  end

  it "should send accepted message" do
    old_admin_count = User.where(username: 'enjuadmin').first.received_messages.count
    old_user_count = reserves(:reserve_00002).user.received_messages.count
    reserves(:reserve_00002).send_message.should be_truthy
    # 予約者と図書館の両方に送られる
    User.where(username: 'enjuadmin').first.received_messages.count.should eq old_admin_count + 1
    reserves(:reserve_00002).user.received_messages.count.should eq old_user_count + 1
  end

  it "should send expired message" do
    old_count = Message.count
    reserves(:reserve_00006).send_message.should be_truthy
    Message.count.should eq old_count + 2
  end

  it "should have reservations that will be expired" do
    reserve = FactoryBot.create(:reserve)
    item = FactoryBot.create(:item, manifestation_id: reserve.manifestation.id)
    item.retain(reserve.user)
    reserve.reload
    reserve.expired_at = Date.yesterday
    reserve.save!(validate: false)
    expect(Reserve.will_expire_retained(Time.zone.now)).to include reserve
  end

  it "should have completed reservation" do
    reserve = FactoryBot.create(:reserve)
    item = FactoryBot.create(:item, manifestation_id: reserve.manifestation.id)
    item.checkout!(reserve.user)
    expect(Reserve.completed).to include reserve
  end

  it "should expire all reservations" do
    assert Reserve.expire.should be_truthy
  end

  it "should send accepted notification" do
    assert Reserve.expire.should be_truthy
  end

  it "should nullify the first reservation's item_id if the second reservation is retained" do
    reservation = reserves(:reserve_00015)
    old_reservation = reserves(:reserve_00014)
    old_count = Message.count

    reservation.item = old_reservation.item
    expect(reservation).not_to be_retained
    reservation.transition_to!(:retained)
    old_reservation.reload
    old_reservation.item.should be_nil
    reservation.retained_at.should be_truthy
#    old_reservation.retained_at.should be_nil
#    old_reservation.postponed_at.should be_truthy
    old_reservation.current_state.should eq 'postponed'
    Message.count.should eq old_count + 4
    reservation.item.retained?.should be_truthy
  end

  it "should not be valid if item_identifier is invalid" do
    reservation = reserves(:reserve_00014)
    reservation.item_identifier = 'invalid'
    reservation.save
    assert reservation.valid?.should eq false
  end

  it "should be valid if the reservation is completed and its item is destroyed" do
    reservation = reserves(:reserve_00010)
    reservation.item.destroy
    reservation.reload
    assert reservation.should be_valid
  end

  it "should be treated as Waiting" do
    reserve = FactoryBot.create(:reserve)
    expect(Reserve.waiting).to include reserve
    reserve = FactoryBot.create(:reserve, expired_at: nil)
    expect(Reserve.waiting).to include reserve
  end

  it "should not retain against reserves with already retained" do
    reserve = FactoryBot.create(:reserve)
    manifestation = reserve.manifestation
    item = FactoryBot.create(:item, manifestation_id: manifestation.id)
    expect {item.retain(reserve.user)}.not_to raise_error
    expect(reserve.retained?).to be true
    expect(item.retained?).to be true
    item = FactoryBot.create(:item, manifestation_id: manifestation.id)
    expect {item.retain(reserve.user)}.not_to raise_error
    expect(reserve.retained?).to be true
    expect(item.retained?).to be false
  end
end

# == Schema Information
#
# Table name: reserves
#
#  id                           :bigint           not null, primary key
#  canceled_at                  :datetime
#  checked_out_at               :datetime
#  expiration_notice_to_library :boolean          default(FALSE)
#  expiration_notice_to_patron  :boolean          default(FALSE)
#  expired_at                   :datetime
#  lock_version                 :integer          default(0), not null
#  postponed_at                 :datetime
#  retained_at                  :datetime
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  item_id                      :bigint
#  manifestation_id             :bigint           not null
#  pickup_location_id           :bigint
#  request_status_type_id       :bigint           not null
#  user_id                      :bigint           not null
#
# Indexes
#
#  index_reserves_on_item_id             (item_id)
#  index_reserves_on_manifestation_id    (manifestation_id)
#  index_reserves_on_pickup_location_id  (pickup_location_id)
#  index_reserves_on_user_id             (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (manifestation_id => manifestations.id)
#  fk_rails_...  (user_id => users.id)
#
