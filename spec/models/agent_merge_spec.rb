require 'rails_helper'

describe AgentMerge do
  # pending "add some examples to (or delete) #{__FILE__}"

end

# ## Schema Information
#
# Table name: `agent_merges`
#
# ### Columns
#
# Name                       | Type               | Attributes
# -------------------------- | ------------------ | ---------------------------
# **`id`**                   | `bigint`           | `not null, primary key`
# **`created_at`**           | `datetime`         | `not null`
# **`updated_at`**           | `datetime`         | `not null`
# **`agent_id`**             | `bigint`           | `not null`
# **`agent_merge_list_id`**  | `bigint`           | `not null`
#
# ### Indexes
#
# * `index_agent_merges_on_agent_id`:
#     * **`agent_id`**
# * `index_agent_merges_on_agent_merge_list_id`:
#     * **`agent_merge_list_id`**
#
