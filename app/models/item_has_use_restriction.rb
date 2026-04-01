class ItemHasUseRestriction < ApplicationRecord
  belongs_to :item
  belongs_to :use_restriction
  accepts_nested_attributes_for :use_restriction

  validates :item, presence: { on: :update }

  paginates_per 10
end

# ## Schema Information
#
# Table name: `item_has_use_restrictions`
#
# ### Columns
#
# Name                      | Type               | Attributes
# ------------------------- | ------------------ | ---------------------------
# **`id`**                  | `bigint`           | `not null, primary key`
# **`created_at`**          | `datetime`         | `not null`
# **`updated_at`**          | `datetime`         | `not null`
# **`item_id`**             | `bigint`           | `not null`
# **`use_restriction_id`**  | `bigint`           | `not null`
#
# ### Indexes
#
# * `index_item_has_use_restrictions_on_item_and_use_restriction` (_unique_):
#     * **`item_id`**
#     * **`use_restriction_id`**
# * `index_item_has_use_restrictions_on_use_restriction_id`:
#     * **`use_restriction_id`**
#
# ### Foreign Keys
#
# * `fk_rails_...`:
#     * **`item_id => items.id`**
# * `fk_rails_...`:
#     * **`use_restriction_id => use_restrictions.id`**
#
