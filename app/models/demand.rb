class Demand < ApplicationRecord
  belongs_to :user
  belongs_to :item
  belongs_to :message
end

# ## Schema Information
#
# Table name: `demands`
#
# ### Columns
#
# Name              | Type               | Attributes
# ----------------- | ------------------ | ---------------------------
# **`id`**          | `bigint`           | `not null, primary key`
# **`created_at`**  | `datetime`         | `not null`
# **`updated_at`**  | `datetime`         | `not null`
# **`item_id`**     | `bigint`           |
# **`message_id`**  | `bigint`           |
# **`user_id`**     | `bigint`           | `not null`
#
# ### Indexes
#
# * `index_demands_on_item_id`:
#     * **`item_id`**
# * `index_demands_on_message_id`:
#     * **`message_id`**
# * `index_demands_on_user_id`:
#     * **`user_id`**
#
# ### Foreign Keys
#
# * `fk_rails_...`:
#     * **`item_id => items.id`**
# * `fk_rails_...`:
#     * **`message_id => messages.id`**
# * `fk_rails_...`:
#     * **`user_id => users.id`**
#
