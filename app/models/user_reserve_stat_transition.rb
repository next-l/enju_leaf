class UserReserveStatTransition < ApplicationRecord
  belongs_to :user_reserve_stat, inverse_of: :user_reserve_stat_transitions
end

# ## Schema Information
#
# Table name: `user_reserve_stat_transitions`
#
# ### Columns
#
# Name                        | Type               | Attributes
# --------------------------- | ------------------ | ---------------------------
# **`id`**                    | `bigint`           | `not null, primary key`
# **`metadata`**              | `jsonb`            | `not null`
# **`most_recent`**           | `boolean`          | `not null`
# **`sort_key`**              | `integer`          |
# **`to_state`**              | `string`           |
# **`created_at`**            | `datetime`         | `not null`
# **`updated_at`**            | `datetime`         | `not null`
# **`user_reserve_stat_id`**  | `bigint`           |
#
# ### Indexes
#
# * `index_user_reserve_stat_transitions_on_sort_key_and_stat_id` (_unique_):
#     * **`sort_key`**
#     * **`user_reserve_stat_id`**
# * `index_user_reserve_stat_transitions_on_user_reserve_stat_id`:
#     * **`user_reserve_stat_id`**
# * `index_user_reserve_stat_transitions_parent_most_recent` (_unique_ _where_ most_recent):
#     * **`user_reserve_stat_id`**
#     * **`most_recent`**
#
