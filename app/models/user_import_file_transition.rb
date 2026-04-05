class UserImportFileTransition < ApplicationRecord
  belongs_to :user_import_file, inverse_of: :user_import_file_transitions
end

# ## Schema Information
#
# Table name: `user_import_file_transitions`
#
# ### Columns
#
# Name                       | Type               | Attributes
# -------------------------- | ------------------ | ---------------------------
# **`id`**                   | `bigint`           | `not null, primary key`
# **`metadata`**             | `jsonb`            | `not null`
# **`most_recent`**          | `boolean`          | `not null`
# **`sort_key`**             | `integer`          |
# **`to_state`**             | `string`           |
# **`created_at`**           | `datetime`         | `not null`
# **`updated_at`**           | `datetime`         | `not null`
# **`user_import_file_id`**  | `bigint`           |
#
# ### Indexes
#
# * `index_user_import_file_transitions_on_sort_key_and_file_id` (_unique_):
#     * **`sort_key`**
#     * **`user_import_file_id`**
# * `index_user_import_file_transitions_on_user_import_file_id`:
#     * **`user_import_file_id`**
# * `index_user_import_file_transitions_parent_most_recent` (_unique_ _where_ most_recent):
#     * **`user_import_file_id`**
#     * **`most_recent`**
#
