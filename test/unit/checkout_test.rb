require 'test_helper'

class CheckoutTest < ActiveSupport::TestCase
  fixtures :checkouts, :items, :users, :libraries

  # Replace this with your real tests.
  def test_checkout_not_returned
    assert Checkout.not_returned.size
  end

  def test_checkout_overdue
    assert Checkout.overdue(Time.zone.now).size > 0
    assert Checkout.not_returned.size > Checkout.overdue(Time.zone.now).size
  end

  def test_send_due_date_notification
    assert Checkout.send_due_date_notification
  end

  def test_send_overdue_notification
    assert_equal Checkout.send_overdue_notification, 0
  end

  test "should respond to checkout_renewable?" do
    assert checkouts(:checkout_00001).checkout_renewable?
    assert !checkouts(:checkout_00002).checkout_renewable?
  end

  test "should respond to reserved?" do
    assert !checkouts(:checkout_00001).reserved?
    assert checkouts(:checkout_00002).reserved?
  end

  test "should respond to overdue?" do
    assert !checkouts(:checkout_00001).overdue?
    assert checkouts(:checkout_00006).overdue?
  end

  test "should respond to is_today_due_date?" do
    assert !checkouts(:checkout_00001).is_today_due_date?
  end
end
