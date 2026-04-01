class ItemCustomProperty < ApplicationRecord
  include MasterModel
  validates :name, presence: true, uniqueness: true
  acts_as_list
end

# ## Schema Information
#
# Table name: `item_custom_properties`
#
# ### Columns
#
# Name                        | Type               | Attributes
# --------------------------- | ------------------ | ---------------------------
# **`id`**                    | `bigint`           | `not null, primary key`
# **`display_name(表示名)`**  | `text`             | `not null`
# **`name(ラベル名)`**        | `string`           | `not null`
# **`note(備考)`**            | `text`             |
# **`position`**              | `integer`          | `default(1), not null`
# **`created_at`**            | `datetime`         | `not null`
# **`updated_at`**            | `datetime`         | `not null`
#
# ### Indexes
#
# * `index_item_custom_properties_on_lower_name` (_unique_):
#     * **`lower((name)::text)`**
#
