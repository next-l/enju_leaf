class Participate < ApplicationRecord
  belongs_to :agent
  belongs_to :event

  validates :agent_id, uniqueness: { scope: :event_id }
  acts_as_list scope: :event_id

  paginates_per 10
end

# ## Schema Information
#
# Table name: `participates`
#
# ### Columns
#
# Name              | Type               | Attributes
# ----------------- | ------------------ | ---------------------------
# **`id`**          | `bigint`           | `not null, primary key`
# **`position`**    | `integer`          |
# **`created_at`**  | `datetime`         | `not null`
# **`updated_at`**  | `datetime`         | `not null`
# **`agent_id`**    | `bigint`           | `not null`
# **`event_id`**    | `bigint`           | `not null`
#
# ### Indexes
#
# * `index_participates_on_agent_id`:
#     * **`agent_id`**
# * `index_participates_on_event_id`:
#     * **`event_id`**
#
