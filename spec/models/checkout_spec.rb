require 'rails_helper'

describe Checkout do
  # pending "add some examples to (or delete) #{__FILE__}"
  fixtures :all

  it "should respond to renewable?" do
    checkouts(:checkout_00001).save
    expect(checkouts(:checkout_00001).errors[:base]).to eq []
    checkouts(:checkout_00002).save
    expect(checkouts(:checkout_00002).errors[:base]).to eq [ I18n.t('checkout.this_item_is_reserved') ]
  end

  it "should respond to reserved?" do
    checkouts(:checkout_00001).reserved?.should be_falsy
    checkouts(:checkout_00002).reserved?.should be_truthy
  end

  it "should respond to overdue?" do
    checkouts(:checkout_00001).overdue?.should be_falsy
    checkouts(:checkout_00006).overdue?.should be_truthy
  end

  it "should respond to is_today_due_date?" do
    checkouts(:checkout_00001).is_today_due_date?.should be_falsy
  end

  it "should get new due_date" do
    old_due_date = checkouts(:checkout_00001).due_date
    new_due_date = checkouts(:checkout_00001).get_new_due_date
    new_due_date.should eq Time.zone.now.advance(days: UserGroupHasCheckoutType.find(3).checkout_period).beginning_of_day
  end

  it "should respond to not_returned" do
    Checkout.not_returned.size.should > 0
  end

  it "should respond to overdue" do
    Checkout.overdue(Time.zone.now).size.should > 0
    Checkout.not_returned.size.should > Checkout.overdue(Time.zone.now).size
  end

  it "should respond to send_due_date_notification" do
    expect(Checkout.send_due_date_notification).to eq 5
  end

  it "should respond to send_overdue_notification" do
    expect(Checkout.send_overdue_notification).to eq 1
  end

  it "should destroy all history" do
    user = users(:user1)
    old_count = Checkout.count
    Checkout.remove_all_history(user)
    expect(user.checkouts.returned.count).to eq 0
    expect(Checkout.count).to eq old_count
  end
end

# ## Schema Information
#
# Table name: `checkouts`
#
# ### Columns
#
# Name                          | Type               | Attributes
# ----------------------------- | ------------------ | ---------------------------
# **`id`**                      | `bigint`           | `not null, primary key`
# **`checkout_renewal_count`**  | `integer`          | `default(0), not null`
# **`due_date`**                | `datetime`         |
# **`lock_version`**            | `integer`          | `default(0), not null`
# **`created_at`**              | `datetime`         | `not null`
# **`updated_at`**              | `datetime`         | `not null`
# **`basket_id`**               | `bigint`           |
# **`checkin_id`**              | `bigint`           |
# **`item_id`**                 | `bigint`           | `not null`
# **`librarian_id`**            | `bigint`           |
# **`library_id`**              | `bigint`           |
# **`shelf_id`**                | `bigint`           |
# **`user_id`**                 | `bigint`           |
#
# ### Indexes
#
# * `index_checkouts_on_basket_id`:
#     * **`basket_id`**
# * `index_checkouts_on_checkin_id`:
#     * **`checkin_id`**
# * `index_checkouts_on_item_id`:
#     * **`item_id`**
# * `index_checkouts_on_item_id_and_basket_id_and_user_id` (_unique_):
#     * **`item_id`**
#     * **`basket_id`**
#     * **`user_id`**
# * `index_checkouts_on_librarian_id`:
#     * **`librarian_id`**
# * `index_checkouts_on_library_id`:
#     * **`library_id`**
# * `index_checkouts_on_shelf_id`:
#     * **`shelf_id`**
# * `index_checkouts_on_user_id`:
#     * **`user_id`**
#
# ### Foreign Keys
#
# * `fk_rails_...`:
#     * **`checkin_id => checkins.id`**
# * `fk_rails_...`:
#     * **`item_id => items.id`**
# * `fk_rails_...`:
#     * **`library_id => libraries.id`**
# * `fk_rails_...`:
#     * **`shelf_id => shelves.id`**
# * `fk_rails_...`:
#     * **`user_id => users.id`**
#
