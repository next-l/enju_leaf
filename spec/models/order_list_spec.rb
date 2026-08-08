require 'rails_helper'

describe OrderList do
  fixtures :all

  it "should calculate total price" do
    order_list = order_lists(:order_list_00001)
    order_list.total_price.should eq 0
    order_list.purchase_requests << purchase_requests(:purchase_request_00006)
    order_list.total_price.should eq purchase_requests(:purchase_request_00006).price
  end
end

# ## Schema Information
#
# Table name: `order_lists`
#
# ### Columns
#
# Name                | Type               | Attributes
# ------------------- | ------------------ | ---------------------------
# **`id`**            | `bigint`           | `not null, primary key`
# **`note`**          | `text`             |
# **`ordered_at`**    | `datetime`         |
# **`title`**         | `text`             | `not null`
# **`created_at`**    | `datetime`         | `not null`
# **`updated_at`**    | `datetime`         | `not null`
# **`bookstore_id`**  | `bigint`           | `not null`
# **`user_id`**       | `bigint`           | `not null`
#
# ### Indexes
#
# * `index_order_lists_on_bookstore_id`:
#     * **`bookstore_id`**
# * `index_order_lists_on_user_id`:
#     * **`user_id`**
#
# ### Foreign Keys
#
# * `fk_rails_...`:
#     * **`bookstore_id => bookstores.id`**
# * `fk_rails_...`:
#     * **`user_id => users.id`**
#
