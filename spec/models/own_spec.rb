require 'rails_helper'

describe Own do
  # pending "add some examples to (or delete) #{__FILE__}"

end

# ## Schema Information
#
# Table name: `owns`
#
# ### Columns
#
# Name              | Type               | Attributes
# ----------------- | ------------------ | ---------------------------
# **`id`**          | `bigint`           | `not null, primary key`
# **`position`**    | `integer`          |
# **`created_at`**  | `datetime`         | `not null`
# **`updated_at`**  | `datetime`         | `not null`
# **`agent_id`**    | `bigint`           | `not null`
# **`item_id`**     | `bigint`           | `not null`
#
# ### Indexes
#
# * `index_owns_on_agent_id`:
#     * **`agent_id`**
# * `index_owns_on_item_id_and_agent_id` (_unique_):
#     * **`item_id`**
#     * **`agent_id`**
#
