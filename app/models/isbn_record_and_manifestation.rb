class IsbnRecordAndManifestation < ApplicationRecord
  belongs_to :isbn_record
  belongs_to :manifestation
  validates :isbn_record_id, uniqueness: { scope: :manifestation_id }
end

# ## Schema Information
#
# Table name: `isbn_record_and_manifestations(書誌とISBNの関係)`
#
# ### Columns
#
# Name                    | Type               | Attributes
# ----------------------- | ------------------ | ---------------------------
# **`id`**                | `bigint`           | `not null, primary key`
# **`created_at`**        | `datetime`         | `not null`
# **`updated_at`**        | `datetime`         | `not null`
# **`isbn_record_id`**    | `bigint`           | `not null`
# **`manifestation_id`**  | `bigint`           | `not null`
#
# ### Indexes
#
# * `index_isbn_record_and_manifestations_on_isbn_record_id`:
#     * **`isbn_record_id`**
# * `index_isbn_record_and_manifestations_on_manifestation_id` (_unique_):
#     * **`manifestation_id`**
#     * **`isbn_record_id`**
#
# ### Foreign Keys
#
# * `fk_rails_...`:
#     * **`isbn_record_id => isbn_records.id`**
# * `fk_rails_...`:
#     * **`manifestation_id => manifestations.id`**
#
