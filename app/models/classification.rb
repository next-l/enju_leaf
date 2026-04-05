class Classification < ApplicationRecord
  belongs_to :classification_type
  belongs_to :manifestation, touch: true, optional: true

  validates :category, presence: true
  searchable do
    text :category, :note
    integer :classification_type_id
  end
  strip_attributes only: [ :category, :url ]

  paginates_per 10
end

# ## Schema Information
#
# Table name: `classifications`
#
# ### Columns
#
# Name                          | Type               | Attributes
# ----------------------------- | ------------------ | ---------------------------
# **`id`**                      | `bigint`           | `not null, primary key`
# **`category`**                | `string`           | `not null`
# **`label`**                   | `string`           |
# **`lft`**                     | `integer`          |
# **`note`**                    | `text`             |
# **`rgt`**                     | `integer`          |
# **`url`**                     | `string`           |
# **`created_at`**              | `datetime`         | `not null`
# **`updated_at`**              | `datetime`         | `not null`
# **`classification_type_id`**  | `bigint`           | `not null`
# **`manifestation_id`**        | `bigint`           |
# **`parent_id`**               | `bigint`           |
#
# ### Indexes
#
# * `index_classifications_on_category`:
#     * **`category`**
# * `index_classifications_on_classification_type_id`:
#     * **`classification_type_id`**
# * `index_classifications_on_manifestation_id`:
#     * **`manifestation_id`**
# * `index_classifications_on_parent_id`:
#     * **`parent_id`**
#
