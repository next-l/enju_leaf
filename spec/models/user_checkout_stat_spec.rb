# -*- encoding: utf-8 -*-
require 'spec_helper'

describe UserCheckoutStat do
  fixtures :user_checkout_stats

  it "calculates user count" do
    user_checkout_stats(:one).calculate_count.should be_true
  end
end
