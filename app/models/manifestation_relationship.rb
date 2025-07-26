class ManifestationRelationship < ApplicationRecord
  belongs_to :parent, class_name: "Manifestation"
  belongs_to :child, class_name: "Manifestation"
  belongs_to :manifestation_relationship_type, optional: true
  validate :check_parent
  acts_as_list scope: :parent_id

  def check_parent
    if parent_id == child_id
      errors.add(:parent)
      errors.add(:child)
    end
  end
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
