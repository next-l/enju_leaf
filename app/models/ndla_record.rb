class NdlaRecord < ApplicationRecord
  belongs_to :agent
  validates :body, presence: true, uniqueness: true
end

# ## Schema Information
#
# Table name: `ndla_records`
#
# ### Columns
#
# Name              | Type               | Attributes
# ----------------- | ------------------ | ---------------------------
# **`id`**          | `bigint`           | `not null, primary key`
# **`body`**        | `string`           | `not null`
# **`created_at`**  | `datetime`         | `not null`
# **`updated_at`**  | `datetime`         | `not null`
# **`agent_id`**    | `bigint`           |
#
# ### Indexes
#
# * `index_ndla_records_on_agent_id`:
#     * **`agent_id`**
# * `index_ndla_records_on_body` (_unique_):
#     * **`body`**
#
# ### Foreign Keys
#
# * `fk_rails_...`:
#     * **`agent_id => agents.id`**
#
