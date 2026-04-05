class SeriesStatementMerge < ApplicationRecord
  belongs_to :series_statement
  belongs_to :series_statement_merge_list

  paginates_per 10
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
