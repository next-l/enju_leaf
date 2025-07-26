require 'spec_helper'

describe UserHasRole do
  #pending "add some examples to (or delete) #{__FILE__}"

end

# ## Schema Information
#
# Table name: `user_has_roles`
#
# ### Columns
#
# Name              | Type               | Attributes
# ----------------- | ------------------ | ---------------------------
# **`id`**          | `bigint`           | `not null, primary key`
# **`created_at`**  | `datetime`         | `not null`
# **`updated_at`**  | `datetime`         | `not null`
# **`role_id`**     | `bigint`           | `not null`
# **`user_id`**     | `bigint`           | `not null`
#
# ### Indexes
#
# * `index_user_has_roles_on_role_id`:
#     * **`role_id`**
# * `index_user_has_roles_on_user_id_and_role_id` (_unique_):
#     * **`user_id`**
#     * **`role_id`**
#
# ### Foreign Keys
#
# * `fk_rails_...`:
#     * **`role_id => roles.id`**
# * `fk_rails_...`:
#     * **`user_id => users.id`**
#
