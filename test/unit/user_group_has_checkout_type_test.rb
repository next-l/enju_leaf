require 'test_helper'

class UserGroupHasCheckoutTypeTest < ActiveSupport::TestCase
  fixtures :user_group_has_checkout_types, :user_groups, :checkout_types,
    :lending_policies, :items
  # Replace this with your real tests.
  
  def test_should_create_lending_policy
    old_lending_policy_count = LendingPolicy.count
    assert user_group_has_checkout_types(:user_group_has_checkout_type_00001).create_lending_policy
    assert old_lending_policy_count + 20, LendingPolicy.count
  end

  def test_should_update_lending_policy
    old_updated_at = lending_policies(:lending_policy_00004).updated_at
    user_group_has_checkout_types(:user_group_has_checkout_type_00002).checkout_period = 100
    assert user_group_has_checkout_types(:user_group_has_checkout_type_00002).update_lending_policy
    lending_policies(:lending_policy_00004).reload
    assert_not_equal old_updated_at, lending_policies(:lending_policy_00004).updated_at
  end

end
