require 'rails_helper'

describe Create do
  # pending "add some examples to (or delete) #{__FILE__}"
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
# **`name`**            | `text`             |
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
# ### Foreign Keys
#
# * `fk_rails_...`:
#     * **`agent_id => agents.id`**
# * `fk_rails_...`:
#     * **`work_id => manifestations.id`**
#
