class BookmarkStatHasManifestation < ApplicationRecord
  belongs_to :bookmark_stat
  belongs_to :manifestation

  validates_uniqueness_of :manifestation_id, scope: :bookmark_stat_id

  paginates_per 10
end

# ## Schema Information
#
# Table name: `bookmark_stat_has_manifestations`
#
# ### Columns
#
# Name                    | Type               | Attributes
# ----------------------- | ------------------ | ---------------------------
# **`id`**                | `bigint`           | `not null, primary key`
# **`bookmarks_count`**   | `integer`          |
# **`created_at`**        | `datetime`         | `not null`
# **`updated_at`**        | `datetime`         | `not null`
# **`bookmark_stat_id`**  | `bigint`           | `not null`
# **`manifestation_id`**  | `bigint`           | `not null`
#
# ### Indexes
#
# * `index_bookmark_stat_has_manifestations_on_bookmark_stat_id`:
#     * **`bookmark_stat_id`**
# * `index_bookmark_stat_has_manifestations_on_manifestation_id`:
#     * **`manifestation_id`**
#
