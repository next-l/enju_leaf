FactoryBot.define do
  factory :subscription do |f|
    f.sequence(:title) {|n| "subscription_#{n}"}
    f.user_id {FactoryBot.create(:user).id}
  end
end

# ## Schema Information
#
# Table name: `subscriptions`
#
# ### Columns
#
# Name                    | Type               | Attributes
# ----------------------- | ------------------ | ---------------------------
# **`id`**                | `bigint`           | `not null, primary key`
# **`note`**              | `text`             |
# **`subscribes_count`**  | `integer`          | `default(0), not null`
# **`title`**             | `text`             | `not null`
# **`created_at`**        | `datetime`         | `not null`
# **`updated_at`**        | `datetime`         | `not null`
# **`order_list_id`**     | `bigint`           |
# **`user_id`**           | `bigint`           | `not null`
#
# ### Indexes
#
# * `index_subscriptions_on_order_list_id`:
#     * **`order_list_id`**
# * `index_subscriptions_on_user_id`:
#     * **`user_id`**
#
# ### Foreign Keys
#
# * `fk_rails_...`:
#     * **`user_id => users.id`**
#
