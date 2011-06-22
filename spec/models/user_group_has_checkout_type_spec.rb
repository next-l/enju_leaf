# -*- encoding: utf-8 -*-
require 'spec_helper'

describe UserGroupHasCheckoutType do
  fixtures :all

  it "should create lending_policy" do
    old_count = LendingPolicy.count
    user_group_has_checkout_types(:user_group_has_checkout_type_00001).create_lending_policy
    user_group_has_checkout_types(:user_group_has_checkout_type_00001).checkout_type.items.count.should eq old_count
  end

  it "should update lending_policy" do
    old_updated_at = lending_policies(:lending_policy_00004).updated_at
    user_group_has_checkout_types(:user_group_has_checkout_type_00002).checkout_period = 100
    user_group_has_checkout_types(:user_group_has_checkout_type_00002).update_lending_policy.should be_true
    lending_policies(:lending_policy_00004).reload
    lending_policies(:lending_policy_00004).updated_at.should > old_updated_at
  end

  it "should respond to update_current_checkout_count" do
    UserGroupHasCheckoutType.update_current_checkout_count.should be_true
  end
end
