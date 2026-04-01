FactoryBot.define do
  factory :user_checkout_stat do
    start_date { 1.week.ago }
    end_date { 1.day.ago }
    association :user, factory: :librarian
  end
end

# ## Schema Information
#
# Table name: `user_checkout_stats`
#
# ### Columns
#
# Name                | Type               | Attributes
# ------------------- | ------------------ | ---------------------------
# **`id`**            | `bigint`           | `not null, primary key`
# **`completed_at`**  | `datetime`         |
# **`end_date`**      | `datetime`         |
# **`note`**          | `text`             |
# **`start_date`**    | `datetime`         |
# **`started_at`**    | `datetime`         |
# **`created_at`**    | `datetime`         | `not null`
# **`updated_at`**    | `datetime`         | `not null`
# **`user_id`**       | `bigint`           | `not null`
#
# ### Indexes
#
# * `index_user_checkout_stats_on_user_id`:
#     * **`user_id`**
#
# ### Foreign Keys
#
# * `fk_rails_...`:
#     * **`user_id => users.id`**
#
