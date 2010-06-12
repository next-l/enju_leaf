require 'test_helper'

class ManifestationCheckoutStatTest < ActiveSupport::TestCase
  fixtures :manifestation_checkout_stats

  test "calculate manifestation count" do
    assert manifestation_checkout_stats(:one).calculate_count
  end
end
