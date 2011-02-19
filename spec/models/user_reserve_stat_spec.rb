# -*- encoding: utf-8 -*-
require 'spec_helper'

describe UserReserveStat do
  fixtures :user_reserve_stats

  it "calculates user count" do
    user_reserve_stats(:one).calculate_count.should be_true
  end
end
