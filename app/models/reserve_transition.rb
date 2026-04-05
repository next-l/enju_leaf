class ReserveTransition < ApplicationRecord
  belongs_to :reserve, inverse_of: :reserve_transitions
end

# ## Schema Information
#
# Table name: `reserve_transitions`
#
# ### Columns
#
# Name               | Type               | Attributes
# ------------------ | ------------------ | ---------------------------
# **`id`**           | `bigint`           | `not null, primary key`
# **`metadata`**     | `jsonb`            | `not null`
# **`most_recent`**  | `boolean`          | `not null`
# **`sort_key`**     | `integer`          |
# **`to_state`**     | `string`           |
# **`created_at`**   | `datetime`         | `not null`
# **`updated_at`**   | `datetime`         | `not null`
# **`reserve_id`**   | `bigint`           |
#
# ### Indexes
#
# * `index_reserve_transitions_on_reserve_id`:
#     * **`reserve_id`**
# * `index_reserve_transitions_on_sort_key_and_reserve_id` (_unique_):
#     * **`sort_key`**
#     * **`reserve_id`**
# * `index_reserve_transitions_parent_most_recent` (_unique_ _where_ most_recent):
#     * **`reserve_id`**
#     * **`most_recent`**
#
