class FormOfWork < ApplicationRecord
  include MasterModel
  has_many :works, class_name: "Manifestation" # , dependent: :restrict_with_exception
end

# ## Schema Information
#
# Table name: `form_of_works`
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
# * `index_form_of_works_on_lower_name` (_unique_):
#     * **`lower((name)::text)`**
#
