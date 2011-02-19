# -*- encoding: utf-8 -*-
require 'spec_helper'

describe Subscription do
  fixtures :subscriptions, :manifestations, :subscribes

  it "should_respond_to_subscribed" do
    subscriptions(:subscription_00001).subscribed(manifestations(:manifestation_00001)).should be_true
  end
end
