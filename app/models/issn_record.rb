class IssnRecord < ApplicationRecord
  belongs_to :resource, polymorphic: true
  validates :body, presence: true, uniqueness: { scope: [ :resource_id, :resource_type ] }
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
# Name                   | Type               | Attributes
# ---------------------- | ------------------ | ---------------------------
# **`id`**               | `bigint`           | `not null, primary key`
# **`body(ISSN)`**       | `string`           | `not null`
# **`resource_type`**    | `string`           | `not null`
# **`created_at`**       | `datetime`         | `not null`
# **`updated_at`**       | `datetime`         | `not null`
# **`resource_id`**      | `bigint`           | `not null`
#
# ### Indexes
#
# * `index_issn_records_on_body` (_unique_):
#     * **`body`**
# * `index_issn_records_on_resource_id_and_resource_type_and_body` (_unique_):
#     * **`resource_id`**
#     * **`resource_type`**
#     * **`body`**
#
