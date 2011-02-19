# -*- encoding: utf-8 -*-
require 'spec_helper'

describe BookmarkStat do
  fixtures :bookmark_stats

  it "calculates manifestation count" do
    bookmark_stats(:bookmark_stat_00001).calculate_count.should be_true
  end
end
