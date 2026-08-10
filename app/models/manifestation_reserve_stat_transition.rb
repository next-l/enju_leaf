class ManifestationReserveStatTransition < ApplicationRecord
  belongs_to :manifestation_reserve_stat, inverse_of: :manifestation_reserve_stat_transitions
end

# ## Schema Information
#
# Table name: `manifestation_reserve_stat_transitions`
#
# ### Columns
#
# Name                                 | Type               | Attributes
# ------------------------------------ | ------------------ | ---------------------------
# **`id`**                             | `bigint`           | `not null, primary key`
# **`metadata`**                       | `jsonb`            | `not null`
# **`most_recent`**                    | `boolean`          | `not null`
# **`sort_key`**                       | `integer`          |
# **`to_state`**                       | `string`           |
# **`created_at`**                     | `datetime`         | `not null`
# **`updated_at`**                     | `datetime`         | `not null`
# **`manifestation_reserve_stat_id`**  | `bigint`           |
#
# ### Indexes
#
# * `index_manifestation_reserve_stat_transitions_on_stat_id`:
#     * **`manifestation_reserve_stat_id`**
# * `index_manifestation_reserve_stat_transitions_on_transition` (_unique_):
#     * **`sort_key`**
#     * **`manifestation_reserve_stat_id`**
# * `index_manifestation_reserve_stat_transitions_parent_most_recen` (_unique_ _where_ most_recent):
#     * **`manifestation_reserve_stat_id`**
#     * **`most_recent`**
#
