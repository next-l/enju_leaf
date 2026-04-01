class EventCategory < ApplicationRecord
  # include MasterModel
  validates :name, presence: true
  positioned
  default_scope { order("position") }
  has_many :events, dependent: :restrict_with_exception

  paginates_per 10
end

# ## Schema Information
#
# Table name: `event_categories`
# Database name: `primary`
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
