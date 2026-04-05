FactoryBot.define do
  factory :user_reserve_stat do
    start_date { 1.week.ago }
    end_date { 1.day.ago }
    association :user, factory: :librarian
  end
end

# ## Schema Information
#
# Table name: `user_reserve_stats`
# Database name: `primary`
#
# ### Columns
#
# Name              | Type               | Attributes
# ----------------- | ------------------ | ---------------------------
# **`id`**          | `bigint`           | `not null, primary key`
# **`end_date`**    | `datetime`         | `not null`
# **`note`**        | `text`             |
# **`start_date`**  | `datetime`         | `not null`
# **`created_at`**  | `datetime`         | `not null`
# **`updated_at`**  | `datetime`         | `not null`
# **`user_id`**     | `bigint`           | `not null`
#
# ### Indexes
#
# * `index_user_reserve_stats_on_user_id`:
#     * **`user_id`**
#
# ### Foreign Keys
#
# * `fk_rails_...`:
#     * **`user_id => users.id`**
#
