# ## Schema Information
#
# Table name: `series_statement_merge_lists`
#
# ### Columns
#
# Name              | Type               | Attributes
# ----------------- | ------------------ | ---------------------------
# **`id`**          | `bigint`           | `not null, primary key`
# **`title`**       | `string`           | `not null`
# **`created_at`**  | `datetime`         | `not null`
# **`updated_at`**  | `datetime`         | `not null`
#
class SeriesStatementMergeList < ApplicationRecord
  has_many :series_statement_merges, dependent: :destroy
  has_many :series_statements, through: :series_statement_merges
  validates :title, presence: true

  paginates_per 10
end
