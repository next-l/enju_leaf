class Accept < ApplicationRecord
  include EnjuCirculation::EnjuAccept
  default_scope { order("accepts.id DESC") }
  belongs_to :basket
  belongs_to :item, touch: true
  belongs_to :librarian, class_name: "User"

  validates :item_id, uniqueness: true # , message:  I18n.t('accept.already_accepted')

  attr_accessor :item_identifier

  paginates_per 10
end

# ## Schema Information
#
# Table name: `accepts`
#
# ### Columns
#
# Name                | Type               | Attributes
# ------------------- | ------------------ | ---------------------------
# **`id`**            | `bigint`           | `not null, primary key`
# **`created_at`**    | `datetime`         | `not null`
# **`updated_at`**    | `datetime`         | `not null`
# **`basket_id`**     | `bigint`           |
# **`item_id`**       | `bigint`           |
# **`librarian_id`**  | `bigint`           |
#
# ### Indexes
#
# * `index_accepts_on_basket_id`:
#     * **`basket_id`**
# * `index_accepts_on_item_id` (_unique_):
#     * **`item_id`**
# * `index_accepts_on_librarian_id`:
#     * **`librarian_id`**
#
