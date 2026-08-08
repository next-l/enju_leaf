class AgentRelationshipType < ApplicationRecord
  include MasterModel
  default_scope { order("agent_relationship_types.position") }
  has_many :agent_relationships, dependent: :destroy
end

# ## Schema Information
#
# Table name: `agent_relationship_types`
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
# * `index_agent_relationship_types_on_lower_name` (_unique_):
#     * **`lower((name)::text)`**
#
