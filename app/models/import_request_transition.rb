class ImportRequestTransition < ApplicationRecord
  belongs_to :import_request, inverse_of: :import_request_transitions
end

# ## Schema Information
#
# Table name: `import_request_transitions`
#
# ### Columns
#
# Name                     | Type               | Attributes
# ------------------------ | ------------------ | ---------------------------
# **`id`**                 | `bigint`           | `not null, primary key`
# **`metadata`**           | `jsonb`            | `not null`
# **`most_recent`**        | `boolean`          | `not null`
# **`sort_key`**           | `integer`          |
# **`to_state`**           | `string`           |
# **`created_at`**         | `datetime`         | `not null`
# **`updated_at`**         | `datetime`         | `not null`
# **`import_request_id`**  | `bigint`           |
#
# ### Indexes
#
# * `index_import_request_transitions_on_import_request_id`:
#     * **`import_request_id`**
# * `index_import_request_transitions_on_sort_key_and_request_id` (_unique_):
#     * **`sort_key`**
#     * **`import_request_id`**
# * `index_import_request_transitions_parent_most_recent` (_unique_ _where_ most_recent):
#     * **`import_request_id`**
#     * **`most_recent`**
#
