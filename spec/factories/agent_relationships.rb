FactoryBot.define do
  factory :agent_relationship do |f|
    f.parent_id {FactoryBot.create(:agent).id}
    f.child_id {FactoryBot.create(:agent).id}
    f.association :agent_relationship_type
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
