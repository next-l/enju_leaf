class BookmarkStatTransition < ApplicationRecord
  belongs_to :bookmark_stat, inverse_of: :bookmark_stat_transitions
end

# ## Schema Information
#
# Table name: `bookmark_stat_transitions`
#
# ### Columns
#
# Name                    | Type               | Attributes
# ----------------------- | ------------------ | ---------------------------
# **`id`**                | `bigint`           | `not null, primary key`
# **`metadata`**          | `jsonb`            | `not null`
# **`most_recent`**       | `boolean`          | `not null`
# **`sort_key`**          | `integer`          |
# **`to_state`**          | `string`           |
# **`created_at`**        | `datetime`         | `not null`
# **`updated_at`**        | `datetime`         | `not null`
# **`bookmark_stat_id`**  | `bigint`           |
#
# ### Indexes
#
# * `index_bookmark_stat_transitions_on_bookmark_stat_id`:
#     * **`bookmark_stat_id`**
# * `index_bookmark_stat_transitions_on_sort_key_and_stat_id` (_unique_):
#     * **`sort_key`**
#     * **`bookmark_stat_id`**
# * `index_bookmark_stat_transitions_parent_most_recent` (_unique_ _where_ most_recent):
#     * **`bookmark_stat_id`**
#     * **`most_recent`**
#
