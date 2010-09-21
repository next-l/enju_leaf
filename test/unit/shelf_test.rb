require 'test_helper'

class ShelfTest < ActiveSupport::TestCase
  fixtures :shelves

  test "should respond to web_shelf" do
    assert shelves(:shelf_00001).web_shelf?
    assert !shelves(:shelf_00002).web_shelf?
  end
end
