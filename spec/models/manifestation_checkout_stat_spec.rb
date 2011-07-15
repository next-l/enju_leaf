# -*- encoding: utf-8 -*-
require 'spec_helper'

describe ManifestationCheckoutStat do
  fixtures :manifestation_checkout_stats

  it "calculates manifestation count" do
    manifestation_checkout_stats(:one).calculate_count.should be_true
  end
end

# == Schema Information
#
# Table name: manifestation_checkout_stats
#
#  id           :integer         not null, primary key
#  start_date   :datetime
#  end_date     :datetime
#  note         :text
#  state        :string(255)
#  created_at   :datetime
#  updated_at   :datetime
#  started_at   :datetime
#  completed_at :datetime
#

