FactoryBot.define do
  factory :bookmark_stat do |f|
    f.start_date { 1.week.ago }
    f.end_date { 1.day.ago }
  end
end

# ## Schema Information
#
# Table name: `bookmark_stats`
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
#
