require 'rails_helper'

describe Checkout do
  # pending "add some examples to (or delete) #{__FILE__}"
  fixtures :all

  it "should respond to renewable?" do
    checkouts(:checkout_00001).save
    checkouts(:checkout_00001).errors[:base].should eq []
    checkouts(:checkout_00002).save
    checkouts(:checkout_00002).errors[:base].should eq [I18n.t('checkout.this_item_is_reserved')]
  end

  it "should respond to reserved?" do
    checkouts(:checkout_00001).reserved?.should be_falsy
    checkouts(:checkout_00002).reserved?.should be_truthy
  end

  it "should respond to overdue?" do
    checkouts(:checkout_00001).overdue?.should be_falsy
    checkouts(:checkout_00006).overdue?.should be_truthy
  end

  it "should respond to is_today_due_date?" do
    checkouts(:checkout_00001).is_today_due_date?.should be_falsy
  end

  it "should get new due_date" do
    old_due_date = checkouts(:checkout_00001).due_date
    new_due_date = checkouts(:checkout_00001).get_new_due_date
    new_due_date.should eq Time.zone.now.advance(days: UserGroupHasCheckoutType.find(3).checkout_period).beginning_of_day
  end

  it "should respond to not_returned" do
    Checkout.not_returned.size.should > 0
  end

  it "should respond to overdue" do
    Checkout.overdue(Time.zone.now).size.should > 0
    Checkout.not_returned.size.should > Checkout.overdue(Time.zone.now).size
  end

  it "should respond to send_due_date_notification" do
    Checkout.send_due_date_notification.should eq 5
  end

  it "should respond to send_overdue_notification" do
    Checkout.send_overdue_notification.should eq 1
  end

  it "should destroy all history" do
    user = users(:user1)
    old_count = Checkout.count
    Checkout.remove_all_history(user)
    user.checkouts.returned.count.should eq 0
    Checkout.count.should eq old_count
  end
end

# == Schema Information
#
# Table name: checkouts
#
#  id                     :bigint           not null, primary key
#  user_id                :bigint
#  item_id                :bigint           not null
#  checkin_id             :integer
#  librarian_id           :bigint
#  basket_id              :bigint
#  due_date               :datetime
#  checkout_renewal_count :integer          default(0), not null
#  lock_version           :integer          default(0), not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  shelf_id               :bigint
#  library_id             :bigint
#
