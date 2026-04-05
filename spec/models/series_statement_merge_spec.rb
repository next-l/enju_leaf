require 'rails_helper'

describe SeriesStatementMerge do
  # pending "add some examples to (or delete) #{__FILE__}"
end

# ## Schema Information
#
# Table name: `series_statement_merges`
#
# ### Columns
#
# Name                                  | Type               | Attributes
# ------------------------------------- | ------------------ | ---------------------------
# **`id`**                              | `bigint`           | `not null, primary key`
# **`created_at`**                      | `datetime`         | `not null`
# **`updated_at`**                      | `datetime`         | `not null`
# **`series_statement_id`**             | `bigint`           | `not null`
# **`series_statement_merge_list_id`**  | `bigint`           | `not null`
#
# ### Indexes
#
# * `index_series_statement_merges_on_list_id`:
#     * **`series_statement_merge_list_id`**
# * `index_series_statement_merges_on_series_statement_id`:
#     * **`series_statement_id`**
#
