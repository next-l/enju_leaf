class ReserveStatHasUser < ApplicationRecord
  belongs_to :user_reserve_stat
  belongs_to :user

  validates :user_id, uniqueness: { scope: :user_reserve_stat_id }

  paginates_per 10
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
