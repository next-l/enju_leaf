class Order < ApplicationRecord
  belongs_to :order_list, validate: true
  belongs_to :purchase_request, validate: true

  validates_associated :order_list, :purchase_request
  validates_presence_of :order_list, :purchase_request
  validates_uniqueness_of :purchase_request_id, scope: :order_list_id

  after_save :reindex
  after_destroy :reindex

  acts_as_list scope: :order_list

  paginates_per 10

  def reindex
    purchase_request.try(:index)
  end
end

# ## Schema Information
#
# Table name: `orders`
#
# ### Columns
#
# Name                       | Type               | Attributes
# -------------------------- | ------------------ | ---------------------------
# **`id`**                   | `bigint`           | `not null, primary key`
# **`position`**             | `integer`          |
# **`created_at`**           | `datetime`         | `not null`
# **`updated_at`**           | `datetime`         | `not null`
# **`order_list_id`**        | `bigint`           | `not null`
# **`purchase_request_id`**  | `bigint`           | `not null`
#
# ### Indexes
#
# * `index_orders_on_order_list_id`:
#     * **`order_list_id`**
# * `index_orders_on_purchase_request_id`:
#     * **`purchase_request_id`**
#
# ### Foreign Keys
#
# * `fk_rails_...`:
#     * **`order_list_id => order_lists.id`**
# * `fk_rails_...`:
#     * **`purchase_request_id => purchase_requests.id`**
#
