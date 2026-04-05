class CheckoutStatHasManifestation < ApplicationRecord
  belongs_to :manifestation_checkout_stat
  belongs_to :manifestation

  validates :manifestation_id, uniqueness: { scope: :manifestation_checkout_stat_id }

  paginates_per 10
end

# ## Schema Information
#
# Table name: `checkout_stat_has_manifestations`
#
# ### Columns
#
# Name                                  | Type               | Attributes
# ------------------------------------- | ------------------ | ---------------------------
# **`id`**                              | `bigint`           | `not null, primary key`
# **`checkouts_count`**                 | `integer`          |
# **`created_at`**                      | `datetime`         | `not null`
# **`updated_at`**                      | `datetime`         | `not null`
# **`manifestation_checkout_stat_id`**  | `bigint`           | `not null`
# **`manifestation_id`**                | `bigint`           | `not null`
#
# ### Indexes
#
# * `index_checkout_stat_has_manifestations_on_checkout_stat_id`:
#     * **`manifestation_checkout_stat_id`**
# * `index_checkout_stat_has_manifestations_on_manifestation_id`:
#     * **`manifestation_id`**
#
# ### Foreign Keys
#
# * `fk_rails_...`:
#     * **`manifestation_id => manifestations.id`**
#
