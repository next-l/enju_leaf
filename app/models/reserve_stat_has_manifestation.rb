class ReserveStatHasManifestation < ApplicationRecord
  belongs_to :manifestation_reserve_stat
  belongs_to :manifestation

  validates :manifestation_id, uniqueness: { scope: :manifestation_reserve_stat_id }

  paginates_per 10
end

# ## Schema Information
#
# Table name: `reserve_stat_has_manifestations`
#
# ### Columns
#
# Name                                 | Type               | Attributes
# ------------------------------------ | ------------------ | ---------------------------
# **`id`**                             | `bigint`           | `not null, primary key`
# **`reserves_count`**                 | `integer`          |
# **`created_at`**                     | `datetime`         | `not null`
# **`updated_at`**                     | `datetime`         | `not null`
# **`manifestation_id`**               | `bigint`           | `not null`
# **`manifestation_reserve_stat_id`**  | `bigint`           | `not null`
#
# ### Indexes
#
# * `index_reserve_stat_has_manifestations_on_m_reserve_stat_id`:
#     * **`manifestation_reserve_stat_id`**
# * `index_reserve_stat_has_manifestations_on_manifestation_id`:
#     * **`manifestation_id`**
#
# ### Foreign Keys
#
# * `fk_rails_...`:
#     * **`manifestation_id => manifestations.id`**
#
