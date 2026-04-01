require 'rails_helper'

describe ReserveStatHasUser do
  # pending "add some examples to (or delete) #{__FILE__}"

end

# ## Schema Information
#
# Table name: `reserve_stat_has_users`
#
# ### Columns
#
# Name                        | Type               | Attributes
# --------------------------- | ------------------ | ---------------------------
# **`id`**                    | `bigint`           | `not null, primary key`
# **`reserves_count`**        | `integer`          |
# **`created_at`**            | `datetime`         | `not null`
# **`updated_at`**            | `datetime`         | `not null`
# **`user_id`**               | `bigint`           | `not null`
# **`user_reserve_stat_id`**  | `bigint`           | `not null`
#
# ### Indexes
#
# * `index_reserve_stat_has_users_on_user_id`:
#     * **`user_id`**
# * `index_reserve_stat_has_users_on_user_reserve_stat_id`:
#     * **`user_reserve_stat_id`**
#
# ### Foreign Keys
#
# * `fk_rails_...`:
#     * **`user_id => users.id`**
# * `fk_rails_...`:
#     * **`user_reserve_stat_id => user_reserve_stats.id`**
#
