# ## Schema Information
#
# Table name: `colors`
# Database name: `primary`
#
# ### Columns
#
# Name                    | Type               | Attributes
# ----------------------- | ------------------ | ---------------------------
# **`id`**                | `bigint`           | `not null, primary key`
# **`code`**              | `string`           | `not null`
# **`position`**          | `integer`          |
# **`property`**          | `string`           | `not null`
# **`created_at`**        | `datetime`         | `not null`
# **`updated_at`**        | `datetime`         | `not null`
# **`library_group_id`**  | `bigint`           |
#
# ### Indexes
#
# * `index_colors_on_library_group_id`:
#     * **`library_group_id`**
#
class Color < ApplicationRecord
  belongs_to :library_group
  validates :code, presence: true, format: /\A[A-Fa-f0-9]{6}\Z/
  validates :property, presence: true, uniqueness: true, format: /\A[a-z][0-9a-z_]*[0-9a-z]\Z/

  acts_as_list
end
