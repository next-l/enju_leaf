require 'test_helper'

class ReserveTest < ActiveSupport::TestCase
  fixtures :reserves, :request_status_types, :message_requests

  # Replace this with your real tests.
  def test_should_have_next_reservation
    assert reserves(:reserve_00001).next_reservation
  end

  def test_should_expire_reservation
    reserves(:reserve_00001).expire
    assert_equal 'Expired', reserves(:reserve_00001).request_status_type.name
  end

  def test_should_cancel_reservation
    reserves(:reserve_00001).cancel
    assert reserves(:reserve_00001).canceled_at
    assert_equal 'Cannot Fulfill Request', reserves(:reserve_00001).request_status_type.name
  end

  def test_should_not_have_next_reservation
    assert_nil reserves(:reserve_00002).next_reservation
  end

  def test_should_send_accepted_message
    old_count = MessageRequest.count
    assert reserves(:reserve_00002).send_message('accepted')
    # 予約者と図書館の両方に送られる
    assert_equal old_count + 2, MessageRequest.count
  end

  def test_should_send_expired_message
    old_count = MessageRequest.count
    assert reserves(:reserve_00002).send_message('expired')
    assert_equal old_count + 1, MessageRequest.count
  end

  def test_should_send_message_to_library
    assert Reserve.send_message_to_library('expired', :manifestations => Reserve.not_sent_expiration_notice_to_library.collect(&:manifestation))
  end

  def test_should_have_reservations_that_will_expire
    assert_equal 1, Reserve.will_expire_retained(Time.zone.now).size
  end

  def test_should_have_completed_reservation
    assert_equal 1, Reserve.completed.size
  end

  def test_should_expire_all_reservations
    assert Reserve.expire
  end

end
