require 'rails_helper'

describe Participate do
  #pending "add some examples to (or delete) #{__FILE__}"

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
