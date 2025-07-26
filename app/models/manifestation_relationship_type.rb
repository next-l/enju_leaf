class ManifestationRelationshipType < ApplicationRecord
  include MasterModel
  default_scope { order("manifestation_relationship_types.position") }
  has_many :manifestation_relationships, dependent: :destroy
end

# ## Schema Information
#
# Table name: `manifestation_relationship_types`
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
# * `index_manifestation_relationship_types_on_lower_name` (_unique_):
#     * **`lower((name)::text)`**
#
