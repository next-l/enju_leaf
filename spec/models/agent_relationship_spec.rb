require 'rails_helper'

describe AgentRelationship do
  # pending "add some examples to (or delete) #{__FILE__}"

end

# ## Schema Information
#
# Table name: `agent_relationships`
#
# ### Columns
#
# Name                              | Type               | Attributes
# --------------------------------- | ------------------ | ---------------------------
# **`id`**                          | `bigint`           | `not null, primary key`
# **`position`**                    | `integer`          |
# **`created_at`**                  | `datetime`         | `not null`
# **`updated_at`**                  | `datetime`         | `not null`
# **`agent_relationship_type_id`**  | `bigint`           |
# **`child_id`**                    | `bigint`           |
# **`parent_id`**                   | `bigint`           |
#
# ### Indexes
#
# * `index_agent_relationships_on_child_id`:
#     * **`child_id`**
# * `index_agent_relationships_on_parent_id`:
#     * **`parent_id`**
#
