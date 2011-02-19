# -*- encoding: utf-8 -*-
require 'spec_helper'

describe ManifestationCheckoutStat do
  fixtures :manifestation_checkout_stats

  it "calculates manifestation count" do
    manifestation_checkout_stats(:one).calculate_count.should be_true
  end
end
