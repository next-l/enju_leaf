# -*- encoding: utf-8 -*-
require 'spec_helper'

describe Checkout do
  #pending "add some examples to (or delete) #{__FILE__}"
  fixtures :all

  it "should respond to checkout_renewable?" do
    checkouts(:checkout_00001).checkout_renewable?.should be_true
    checkouts(:checkout_00002).checkout_renewable?.should be_false
  end

  it "should respond to reserved?" do
    checkouts(:checkout_00001).reserved?.should be_false
    checkouts(:checkout_00012).reserved?.should be_true
  end

  it "should respond to overdue?" do
    checkouts(:checkout_00001).overdue?.should be_false
    checkouts(:checkout_00006).overdue?.should be_true
  end

  it "should respond to is_today_due_date?" do
    checkouts(:checkout_00001).is_today_due_date?.should be_false
  end

  it "should respond to not_returned" do
    Checkout.not_returned.size.should > 0
  end

  it "should respond to overdue" do
    Checkout.overdue(Time.zone.now).size.should > 0
    Checkout.not_returned.size.should > Checkout.overdue(Time.zone.now).size
  end

  it "should respond to send_due_date_notification" do
    Checkout.send_due_date_notification.should eq 2
  end

  it "should respond to send_overdue_notification" do
    Checkout.send_overdue_notification.should eq 1
  end
end

# == Schema Information
#
# Table name: checkouts
#
#  id                     :integer         not null, primary key
#  user_id                :integer
#  item_id                :integer         not null
#  checkin_id             :integer
#  librarian_id           :integer
#  basket_id              :integer
#  due_date               :datetime
#  checkout_renewal_count :integer         default(0), not null
#  lock_version           :integer         default(0), not null
#  created_at             :datetime
#  updated_at             :datetime
#

