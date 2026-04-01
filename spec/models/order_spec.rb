require 'rails_helper'

describe Order do
  #pending "add some examples to (or delete) #{__FILE__}"

end

# ## Schema Information
#
# Table name: `orders`
#
# ### Columns
#
# Name                       | Type               | Attributes
# -------------------------- | ------------------ | ---------------------------
# **`id`**                   | `bigint`           | `not null, primary key`
# **`position`**             | `integer`          |
# **`created_at`**           | `datetime`         | `not null`
# **`updated_at`**           | `datetime`         | `not null`
# **`order_list_id`**        | `bigint`           | `not null`
# **`purchase_request_id`**  | `bigint`           | `not null`
#
# ### Indexes
#
# * `index_orders_on_order_list_id`:
#     * **`order_list_id`**
# * `index_orders_on_purchase_request_id`:
#     * **`purchase_request_id`**
#
# ### Foreign Keys
#
# * `fk_rails_...`:
#     * **`order_list_id => order_lists.id`**
# * `fk_rails_...`:
#     * **`purchase_request_id => purchase_requests.id`**
#
