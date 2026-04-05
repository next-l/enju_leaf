class ProduceType < ApplicationRecord
  include MasterModel
  default_scope { order("produce_types.position") }
end

# ## Schema Information
#
# Table name: `produce_types`
#
# ### Columns
#
# Name                | Type               | Attributes
# ------------------- | ------------------ | ---------------------------
# **`id`**            | `bigint`           | `not null, primary key`
# **`display_name`**  | `text`             |
# **`name`**          | `string`           | `not null`
# **`note`**          | `text`             |
# **`position`**      | `integer`          |
# **`created_at`**    | `datetime`         | `not null`
# **`updated_at`**    | `datetime`         | `not null`
#
# ### Indexes
#
# * `index_produce_types_on_lower_name` (_unique_):
#     * **`lower((name)::text)`**
#
