FactoryBot.define do
  factory :manifestation_relationship do
    parent_id { FactoryBot.create(:manifestation).id }
    child_id { FactoryBot.create(:manifestation).id }
    association :manifestation_relationship_type
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
# **`child_id`**                            | `bigint`           | `not null`
# **`manifestation_relationship_type_id`**  | `bigint`           | `not null`
# **`parent_id`**                           | `bigint`           | `not null`
#
# ### Indexes
#
# * `index_manifestation_relationships_on_child_id`:
#     * **`child_id`**
# * `index_manifestation_relationships_on_parent_id`:
#     * **`parent_id`**
#
# ### Foreign Keys
#
# * `fk_rails_...`:
#     * **`child_id => manifestations.id`**
# * `fk_rails_...`:
#     * **`manifestation_relationship_type_id => manifestation_relationship_types.id`**
# * `fk_rails_...`:
#     * **`parent_id => manifestations.id`**
#
