require 'rails_helper'

describe UserGroupHasCheckoutType do
  fixtures :all

  it "should respond to update_current_checkout_count" do
    UserGroupHasCheckoutType.update_current_checkout_count.should be_truthy
  end
end

# == Schema Information
#
# Table name: user_group_has_checkout_types
#
#  id                              :bigint           not null, primary key
#  user_group_id                   :bigint           not null
#  checkout_type_id                :bigint           not null
#  checkout_limit                  :integer          default(0), not null
#  checkout_period                 :integer          default(0), not null
#  checkout_renewal_limit          :integer          default(0), not null
#  reservation_limit               :integer          default(0), not null
#  reservation_expired_period      :integer          default(7), not null
#  set_due_date_before_closing_day :boolean          default(FALSE), not null
#  fixed_due_date                  :datetime
#  note                            :text
#  position                        :integer
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#  current_checkout_count          :integer
#
