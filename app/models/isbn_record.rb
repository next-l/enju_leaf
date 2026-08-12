class IsbnRecord < ApplicationRecord
  belongs_to :resource, polymorphic: true
  before_save :normalize_isbn
  validates :body, presence: true, uniqueness: { scope: [ :resource_id, :resource_type ] }
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
# Name                   | Type               | Attributes
# ---------------------- | ------------------ | ---------------------------
# **`id`**               | `bigint`           | `not null, primary key`
# **`body(ISBN)`**       | `string`           | `not null`
# **`resource_type`**    | `string`           | `not null`
# **`created_at`**       | `datetime`         | `not null`
# **`updated_at`**       | `datetime`         | `not null`
# **`resource_id`**      | `bigint`           | `not null`
#
# ### Indexes
#
# * `index_isbn_records_on_body`:
#     * **`body`**
# * `index_isbn_records_on_resource_id_and_resource_type_and_body` (_unique_):
#     * **`resource_id`**
#     * **`resource_type`**
#     * **`body`**
#
