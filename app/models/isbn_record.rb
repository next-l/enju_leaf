class IsbnRecord < ApplicationRecord
  belongs_to :manifestation
  before_save :normalize_isbn
  validates :body, presence: true
  strip_attributes

  def normalize_isbn
    if StdNum::ISBN.valid?(body)
      self.body = StdNum::ISBN.normalize(body)
    else
      errors.add(:body)
    end
  end

  def valid_isbn?
    StdNum::ISBN.valid?(body)
  end
end

# ## Schema Information
#
# Table name: `isbn_records(ISBN)`
#
# ### Columns
#
# Name                      | Type               | Attributes
# ------------------------- | ------------------ | ---------------------------
# **`id`**                  | `bigint`           | `not null, primary key`
# **`body(ISBN)`**          | `string`           | `not null`
# **`created_at`**          | `datetime`         | `not null`
# **`updated_at`**          | `datetime`         | `not null`
# **`manifestation_id`**    | `bigint`           | `not null`
#
# ### Indexes
#
# * `index_isbn_records_on_body`:
#     * **`body`**
# * `index_isbn_records_on_manifestation_id_and_body` (_unique_):
#     * **`manifestation_id`**
#     * **`body`**
#
# ### Foreign Keys
#
# * `fk_rails_...`:
#     * **`manifestation_id => manifestations.id`**
#
