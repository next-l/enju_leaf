require 'rails_helper'

describe UserGroup do
  fixtures :user_groups

  it "should contain string in its display_name" do
    user_group = user_groups(:user_group_00001)
    user_group.display_name = "en:test"
    user_group.valid?.should be_truthy
  end

  it "should not contain invalid yaml in its display_name" do
    user_group = user_groups(:user_group_00001)
    user_group.display_name = "en:test\r\nja: テスト"
    user_group.valid?.should be_falsy
  end
end

# ## Schema Information
#
# Table name: `user_groups`
#
# ### Columns
#
# Name                                    | Type               | Attributes
# --------------------------------------- | ------------------ | ---------------------------
# **`id`**                                | `bigint`           | `not null, primary key`
# **`display_name`**                      | `text`             |
# **`expired_at`**                        | `datetime`         |
# **`name`**                              | `string`           | `not null`
# **`note`**                              | `text`             |
# **`number_of_day_to_notify_due_date`**  | `integer`          | `default(0), not null`
# **`number_of_day_to_notify_overdue`**   | `integer`          | `default(0), not null`
# **`number_of_time_to_notify_overdue`**  | `integer`          | `default(0), not null`
# **`position`**                          | `integer`          |
# **`valid_period_for_new_user`**         | `integer`          | `default(0), not null`
# **`created_at`**                        | `datetime`         | `not null`
# **`updated_at`**                        | `datetime`         | `not null`
#
# ### Indexes
#
# * `index_user_groups_on_lower_name` (_unique_):
#     * **`lower((name)::text)`**
#
