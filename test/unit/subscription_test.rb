require File.dirname(__FILE__) + '/../test_helper'

class SubscriptionTest < ActiveSupport::TestCase
  fixtures :subscriptions, :resources, :subscribes

  def test_subscription_should_respond_to_subscribed
    assert subscriptions(:subscription_00001).subscribed(Resource.first)
  end
end
