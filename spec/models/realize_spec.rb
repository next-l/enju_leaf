require 'rails_helper'

describe Realize do
  # pending "add some examples to (or delete) #{__FILE__}"
end

# ## Schema Information
#
# Table name: `realizes`
# Database name: `primary`
#
# ### Columns
#
# Name                   | Type               | Attributes
# ---------------------- | ------------------ | ---------------------------
# **`id`**               | `bigint`           | `not null, primary key`
# **`position`**         | `integer`          |
# **`created_at`**       | `datetime`         | `not null`
# **`updated_at`**       | `datetime`         | `not null`
# **`agent_id`**         | `bigint`           | `not null`
# **`expression_id`**    | `bigint`           | `not null`
# **`realize_type_id`**  | `bigint`           |
#
# ### Indexes
#
# * `index_realizes_on_agent_id`:
#     * **`agent_id`**
# * `index_realizes_on_expression_id_and_agent_id` (_unique_):
#     * **`expression_id`**
#     * **`agent_id`**
#
# ### Foreign Keys
#
# * `fk_rails_...`:
#     * **`agent_id => agents.id`**
# * `fk_rails_...`:
#     * **`expression_id => manifestations.id`**
#
