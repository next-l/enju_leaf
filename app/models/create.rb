class Create < ApplicationRecord
  belongs_to :agent
  belongs_to :work, class_name: "Manifestation", touch: true
  belongs_to :create_type, optional: true

  validates :work_id, uniqueness: { scope: :agent_id }
  after_destroy :reindex
  after_save :reindex

  acts_as_list scope: :work

  def reindex
    agent.try(:index)
    work.try(:index)
  end
end

# ## Schema Information
#
# Table name: `creates`
#
# ### Columns
#
# Name                  | Type               | Attributes
# --------------------- | ------------------ | ---------------------------
# **`id`**              | `bigint`           | `not null, primary key`
# **`position`**        | `integer`          |
# **`created_at`**      | `datetime`         | `not null`
# **`updated_at`**      | `datetime`         | `not null`
# **`agent_id`**        | `bigint`           | `not null`
# **`create_type_id`**  | `bigint`           |
# **`work_id`**         | `bigint`           | `not null`
#
# ### Indexes
#
# * `index_creates_on_agent_id`:
#     * **`agent_id`**
# * `index_creates_on_work_id_and_agent_id` (_unique_):
#     * **`work_id`**
#     * **`agent_id`**
#
