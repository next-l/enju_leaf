require 'test_helper'

class SubscriptionTest < ActiveSupport::TestCase
  fixtures :subscriptions, :manifestations, :subscribes

  def test_subscription_should_respond_to_subscribed
    assert subscriptions(:subscription_00001).subscribed(manifestations(:manifestation_00001))
  end
end
