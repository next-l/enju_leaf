require 'rails_helper'

describe CarrierTypeHasCheckoutType do
  # pending "add some examples to (or delete) #{__FILE__}"

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
