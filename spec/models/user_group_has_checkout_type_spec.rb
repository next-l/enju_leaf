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
    user_group_has_checkout_types(:user_group_has_checkout_type_00002).checkout_renewal_limit = 5
    user_group_has_checkout_types(:user_group_has_checkout_type_00002).update_lending_policy.should be_true
    lending_policies(:lending_policy_00004).reload
    lending_policies(:lending_policy_00004).updated_at.should > old_updated_at
    lending_policies(:lending_policy_00004).loan_period.should eq 100
    lending_policies(:lending_policy_00004).renewal.should eq 5
  end

  it "should respond to update_current_checkout_count" do
    UserGroupHasCheckoutType.update_current_checkout_count.should be_true
  end
end

# == Schema Information
#
# Table name: user_group_has_checkout_types
#
#  id                              :integer         not null, primary key
#  user_group_id                   :integer         not null
#  checkout_type_id                :integer         not null
#  checkout_limit                  :integer         default(0), not null
#  checkout_period                 :integer         default(0), not null
#  checkout_renewal_limit          :integer         default(0), not null
#  reservation_limit               :integer         default(0), not null
#  reservation_expired_period      :integer         default(7), not null
#  set_due_date_before_closing_day :boolean         default(FALSE), not null
#  fixed_due_date                  :datetime
#  note                            :text
#  position                        :integer
#  created_at                      :datetime
#  updated_at                      :datetime
#  current_checkout_count          :integer
#

