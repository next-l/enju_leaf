require 'rails_helper'

describe Inventory do
  # pending "add some examples to (or delete) #{__FILE__}"

end

# ## Schema Information
#
# Table name: `inventories`
#
# ### Columns
#
# Name                      | Type               | Attributes
# ------------------------- | ------------------ | ---------------------------
# **`id`**                  | `bigint`           | `not null, primary key`
# **`current_shelf_name`**  | `string`           |
# **`item_identifier`**     | `string`           |
# **`note`**                | `text`             |
# **`created_at`**          | `datetime`         | `not null`
# **`updated_at`**          | `datetime`         | `not null`
# **`inventory_file_id`**   | `bigint`           |
# **`item_id`**             | `bigint`           |
#
# ### Indexes
#
# * `index_inventories_on_current_shelf_name`:
#     * **`current_shelf_name`**
# * `index_inventories_on_inventory_file_id`:
#     * **`inventory_file_id`**
# * `index_inventories_on_item_id`:
#     * **`item_id`**
# * `index_inventories_on_item_identifier`:
#     * **`item_identifier`**
#
