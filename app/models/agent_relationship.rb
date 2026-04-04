class AgentRelationship < ApplicationRecord
  belongs_to :parent, class_name: "Agent"
  belongs_to :child, class_name: "Agent"
  belongs_to :agent_relationship_type, optional: true
  validate :check_parent
  acts_as_list scope: :parent_id

  def check_parent
    errors.add(:parent) if parent_id == child_id
  end
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
# **`agent_relationship_type_id`**  | `bigint`           | `not null`
# **`child_id`**                    | `bigint`           | `not null`
# **`parent_id`**                   | `bigint`           | `not null`
#
# ### Indexes
#
# * `index_agent_relationships_on_child_id`:
#     * **`child_id`**
# * `index_agent_relationships_on_parent_id`:
#     * **`parent_id`**
#
# ### Foreign Keys
#
# * `fk_rails_...`:
#     * **`agent_relationship_type_id => agent_relationship_types.id`**
# * `fk_rails_...`:
#     * **`child_id => agents.id`**
# * `fk_rails_...`:
#     * **`parent_id => agents.id`**
#
