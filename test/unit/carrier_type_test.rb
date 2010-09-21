require 'test_helper'

class CarrierTypeTest < ActiveSupport::TestCase
  fixtures :carrier_types

  test "should respond to mods_type" do
    assert_equal carrier_types(:carrier_type_00001).mods_type, 'text'
    assert_equal carrier_types(:carrier_type_00002).mods_type, 'software, multimedia'
  end
end
