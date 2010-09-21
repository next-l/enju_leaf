require 'test_helper'

class SearchEngineTest < ActiveSupport::TestCase
  fixtures :search_engines

  test "should respond to search_params" do
    assert_equal search_engines(:search_engine_00001).search_params('test'), {:submit => 'Search', :locale => 'ja', :keyword => 'test'}
  end
end
