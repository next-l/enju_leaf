# -*- encoding: utf-8 -*-
require 'spec_helper'

describe ManifestationReserveStat do
  fixtures :manifestation_reserve_stats

  it "calculates manifestation count" do
    manifestation_reserve_stats(:one).calculate_count.should be_true
  end
end
