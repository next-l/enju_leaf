class Place < ApplicationRecord
  has_many :events, dependent: :destroy
  validates :term, presence: true
end

# ## Schema Information
#
# Table name: `places`
#
# ### Columns
#
# Name              | Type               | Attributes
# ----------------- | ------------------ | ---------------------------
# **`id`**          | `bigint`           | `not null, primary key`
# **`city`**        | `text`             |
# **`latitude`**    | `float`            |
# **`longitude`**   | `float`            |
# **`term`**        | `string`           |
# **`created_at`**  | `datetime`         | `not null`
# **`updated_at`**  | `datetime`         | `not null`
# **`country_id`**  | `bigint`           |
#
# ### Indexes
#
# * `index_places_on_country_id`:
#     * **`country_id`**
# * `index_places_on_term`:
#     * **`term`**
#
