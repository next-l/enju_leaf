class IssnRecord < ApplicationRecord
  belongs_to :manifestation
  validates :body, presence: true, uniqueness: true
  before_save :normalize_issn
  strip_attributes

  def normalize_issn
    if StdNum::ISSN.valid?(body)
      self.body = StdNum::ISSN.normalize(body)
    else
      errors.add(:body)
    end
  end
end

# ## Schema Information
#
# Table name: `issn_records(ISSN)`
#
# ### Columns
#
# Name                      | Type               | Attributes
# ------------------------- | ------------------ | ---------------------------
# **`id`**                  | `bigint`           | `not null, primary key`
# **`body(ISSN)`**          | `string`           | `not null`
# **`created_at`**          | `datetime`         | `not null`
# **`updated_at`**          | `datetime`         | `not null`
# **`manifestation_id`**    | `bigint`           | `not null`
#
# ### Indexes
#
# * `index_issn_records_on_body` (_unique_):
#     * **`body`**
# * `index_issn_records_on_manifestation_id_and_body` (_unique_):
#     * **`manifestation_id`**
#     * **`body`**
#
# ### Foreign Keys
#
# * `fk_rails_...`:
#     * **`manifestation_id => manifestations.id`**
#
