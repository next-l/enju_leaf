require 'rails_helper'

describe ManifestationRelationship do
  # pending "add some examples to (or delete) #{__FILE__}"

end

# ## Schema Information
#
# Table name: `manifestation_relationships`
#
# ### Columns
#
# Name                                      | Type               | Attributes
# ----------------------------------------- | ------------------ | ---------------------------
# **`id`**                                  | `bigint`           | `not null, primary key`
# **`position`**                            | `integer`          |
# **`created_at`**                          | `datetime`         | `not null`
# **`updated_at`**                          | `datetime`         | `not null`
# **`child_id`**                            | `bigint`           |
# **`manifestation_relationship_type_id`**  | `bigint`           |
# **`parent_id`**                           | `bigint`           |
#
# ### Indexes
#
# * `index_manifestation_relationships_on_child_id`:
#     * **`child_id`**
# * `index_manifestation_relationships_on_parent_id`:
#     * **`parent_id`**
#
