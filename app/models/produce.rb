class Produce < ApplicationRecord
  belongs_to :agent
  belongs_to :manifestation, touch: true
  belongs_to :produce_type, optional: true
  delegate :original_title, to: :manifestation, prefix: true

  validates :manifestation_id, uniqueness: { scope: :agent_id }
  after_destroy :reindex
  after_save :reindex

  acts_as_list scope: :manifestation

  def reindex
    agent.try(:index)
    manifestation.try(:index)
  end
end

# ## Schema Information
#
# Table name: `produces`
#
# ### Columns
#
# Name                    | Type               | Attributes
# ----------------------- | ------------------ | ---------------------------
# **`id`**                | `bigint`           | `not null, primary key`
# **`name`**              | `text`             |
# **`position`**          | `integer`          |
# **`created_at`**        | `datetime`         | `not null`
# **`updated_at`**        | `datetime`         | `not null`
# **`agent_id`**          | `bigint`           | `not null`
# **`manifestation_id`**  | `bigint`           | `not null`
# **`produce_type_id`**   | `bigint`           |
#
# ### Indexes
#
# * `index_produces_on_agent_id`:
#     * **`agent_id`**
# * `index_produces_on_manifestation_id_and_agent_id` (_unique_):
#     * **`manifestation_id`**
#     * **`agent_id`**
#
# ### Foreign Keys
#
# * `fk_rails_...`:
#     * **`agent_id => agents.id`**
# * `fk_rails_...`:
#     * **`manifestation_id => manifestations.id`**
#
