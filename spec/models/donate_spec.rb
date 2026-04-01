require 'rails_helper'

describe Donate do
  # pending "add some examples to (or delete) #{__FILE__}"

end

# ## Schema Information
#
# Table name: `donates`
#
# ### Columns
#
# Name              | Type               | Attributes
# ----------------- | ------------------ | ---------------------------
# **`id`**          | `bigint`           | `not null, primary key`
# **`created_at`**  | `datetime`         | `not null`
# **`updated_at`**  | `datetime`         | `not null`
# **`agent_id`**    | `bigint`           | `not null`
# **`item_id`**     | `bigint`           | `not null`
#
# ### Indexes
#
# * `index_donates_on_agent_id`:
#     * **`agent_id`**
# * `index_donates_on_item_id`:
#     * **`item_id`**
#
