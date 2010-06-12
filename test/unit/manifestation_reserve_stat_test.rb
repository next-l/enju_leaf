require 'test_helper'

class ManifestationReserveStatTest < ActiveSupport::TestCase
  fixtures :manifestation_reserve_stats

  test "calculate manifestation count" do
    assert manifestation_reserve_stats(:one).calculate_count
  end
end
