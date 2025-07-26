class CarrierTypeHasCheckoutType < ApplicationRecord
  scope :available_for_carrier_type, lambda { |carrier_type| includes(:carrier_type).where("carrier_types.name = ?", carrier_type.name) }
  scope :available_for_user_group, lambda { |user_group| includes(checkout_type: :user_groups).where("user_groups.name = ?", user_group.name) }

  belongs_to :carrier_type
  belongs_to :checkout_type

  validates :checkout_type_id, uniqueness: { scope: :carrier_type_id }

  acts_as_list scope: :carrier_type_id
end

# ## Schema Information
#
# Table name: `carrier_type_has_checkout_types`
#
# ### Columns
#
# Name                    | Type               | Attributes
# ----------------------- | ------------------ | ---------------------------
# **`id`**                | `bigint`           | `not null, primary key`
# **`note`**              | `text`             |
# **`position`**          | `integer`          |
# **`created_at`**        | `datetime`         | `not null`
# **`updated_at`**        | `datetime`         | `not null`
# **`carrier_type_id`**   | `bigint`           | `not null`
# **`checkout_type_id`**  | `bigint`           | `not null`
#
# ### Indexes
#
# * `index_carrier_type_has_checkout_types_on_carrier_type_id` (_unique_):
#     * **`carrier_type_id`**
#     * **`checkout_type_id`**
# * `index_carrier_type_has_checkout_types_on_checkout_type_id`:
#     * **`checkout_type_id`**
#
# ### Foreign Keys
#
# * `fk_rails_...`:
#     * **`carrier_type_id => carrier_types.id`**
# * `fk_rails_...`:
#     * **`checkout_type_id => checkout_types.id`**
#
