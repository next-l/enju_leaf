class IssnRecordAndManifestation < ApplicationRecord
  belongs_to :issn_record
  belongs_to :manifestation
  validates :issn_record_id, uniqueness: { scope: :manifestation_id }
end

# ## Schema Information
#
# Table name: `issn_record_and_manifestations(書誌とISSNの関係)`
#
# ### Columns
#
# Name                    | Type               | Attributes
# ----------------------- | ------------------ | ---------------------------
# **`id`**                | `bigint`           | `not null, primary key`
# **`created_at`**        | `datetime`         | `not null`
# **`updated_at`**        | `datetime`         | `not null`
# **`issn_record_id`**    | `bigint`           | `not null`
# **`manifestation_id`**  | `bigint`           | `not null`
#
# ### Indexes
#
# * `index_issn_record_and_manifestations_on_issn_record_id`:
#     * **`issn_record_id`**
# * `index_issn_record_and_manifestations_on_manifestation_id` (_unique_):
#     * **`manifestation_id`**
#     * **`issn_record_id`**
#
# ### Foreign Keys
#
# * `fk_rails_...`:
#     * **`issn_record_id => issn_records.id`**
# * `fk_rails_...`:
#     * **`manifestation_id => manifestations.id`**
#
