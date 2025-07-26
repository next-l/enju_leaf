require 'rails_helper'

describe Item do
  # pending "add some examples to (or delete) #{__FILE__}"
  fixtures :all

  it "should be rent" do
    items(:item_00001).rent?.should be_truthy
  end

  it "should not be rent" do
    items(:item_00010).rent?.should be_falsy
  end

  it "should be checked out" do
    items(:item_00010).checkout!(users(:admin)).should be_truthy
    items(:item_00010).circulation_status.name.should eq 'On Loan'
  end

  it "should be checked in" do
    items(:item_00001).checkin!.should be_truthy
    expect(items(:item_00001).circulation_status.name).to eq 'Available On Shelf'
  end

  it "should be retained" do
    old_count = Message.count
    items(:item_00013).retain(users(:librarian1)).should be_truthy
    expect(items(:item_00013).reserves.first.current_state).to eq 'retained'
    expect(Message.count).to eq old_count + 4
  end

  it "should not be checked out when it is reserved" do
    items(:item_00012).available_for_checkout?.should be_falsy
  end

  it "should not be able to checkout a removed item" do
    Item.for_checkout.include?(items(:item_00023)).should be_falsy
  end
end

# ## Schema Information
#
# Table name: `items`
#
# ### Columns
#
# Name                           | Type               | Attributes
# ------------------------------ | ------------------ | ---------------------------
# **`id`**                       | `bigint`           | `not null, primary key`
# **`acquired_at`**              | `datetime`         |
# **`binded_at`**                | `datetime`         |
# **`binding_call_number`**      | `string`           |
# **`binding_item_identifier`**  | `string`           |
# **`call_number`**              | `string`           |
# **`include_supplements`**      | `boolean`          | `default(FALSE), not null`
# **`item_identifier`**          | `string`           |
# **`lock_version`**             | `integer`          | `default(0), not null`
# **`memo`**                     | `text`             |
# **`missing_since`**            | `date`             |
# **`note`**                     | `text`             |
# **`price`**                    | `integer`          |
# **`required_score`**           | `integer`          | `default(0), not null`
# **`url`**                      | `string`           |
# **`created_at`**               | `datetime`         | `not null`
# **`updated_at`**               | `datetime`         | `not null`
# **`bookstore_id`**             | `bigint`           |
# **`budget_type_id`**           | `bigint`           |
# **`checkout_type_id`**         | `bigint`           | `default(1), not null`
# **`circulation_status_id`**    | `bigint`           | `default(5), not null`
# **`manifestation_id`**         | `bigint`           | `not null`
# **`required_role_id`**         | `bigint`           | `default(1), not null`
# **`shelf_id`**                 | `bigint`           | `default(1), not null`
#
# ### Indexes
#
# * `index_items_on_binding_item_identifier`:
#     * **`binding_item_identifier`**
# * `index_items_on_bookstore_id`:
#     * **`bookstore_id`**
# * `index_items_on_checkout_type_id`:
#     * **`checkout_type_id`**
# * `index_items_on_circulation_status_id`:
#     * **`circulation_status_id`**
# * `index_items_on_item_identifier` (_unique_ _where_ (((item_identifier)::text <> ''::text) AND (item_identifier IS NOT NULL))):
#     * **`item_identifier`**
# * `index_items_on_manifestation_id`:
#     * **`manifestation_id`**
# * `index_items_on_required_role_id`:
#     * **`required_role_id`**
# * `index_items_on_shelf_id`:
#     * **`shelf_id`**
#
# ### Foreign Keys
#
# * `fk_rails_...`:
#     * **`manifestation_id => manifestations.id`**
# * `fk_rails_...`:
#     * **`required_role_id => roles.id`**
#
