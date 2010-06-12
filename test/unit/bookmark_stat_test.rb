require 'test_helper'

class BookmarkStatTest < ActiveSupport::TestCase
  fixtures :bookmark_stats

  test "calculate manifestation count" do
    assert bookmark_stats(:bookmark_stat_00001).calculate_count
  end
end
