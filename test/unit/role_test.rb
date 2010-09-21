require 'test_helper'

class RoleTest < ActiveSupport::TestCase
  fixtures :roles

  test "should respond to localized_name" do
    assert_equal roles(:role_00001).localized_name, 'Guest'
  end

  test "should respond to default_role" do
    assert_equal Role.default_role, roles(:role_00001)
  end
end
