require 'rails_helper'

describe ResourceImportResult do
  # pending "add some examples to (or delete) #{__FILE__}"

end

# ## Schema Information
#
# Table name: `resource_import_results`
#
# ### Columns
#
# Name                           | Type               | Attributes
# ------------------------------ | ------------------ | ---------------------------
# **`id`**                       | `bigint`           | `not null, primary key`
# **`body`**                     | `text`             |
# **`error_message`**            | `text`             |
# **`created_at`**               | `datetime`         | `not null`
# **`updated_at`**               | `datetime`         | `not null`
# **`item_id`**                  | `bigint`           |
# **`manifestation_id`**         | `bigint`           |
# **`resource_import_file_id`**  | `bigint`           |
#
# ### Indexes
#
# * `index_resource_import_results_on_item_id`:
#     * **`item_id`**
# * `index_resource_import_results_on_manifestation_id`:
#     * **`manifestation_id`**
# * `index_resource_import_results_on_resource_import_file_id`:
#     * **`resource_import_file_id`**
#
