# ## Schema Information
#
# Table name: `news_feeds`
# Database name: `primary`
#
# ### Columns
#
# Name                    | Type               | Attributes
# ----------------------- | ------------------ | ---------------------------
# **`id`**                | `bigint`           | `not null, primary key`
# **`body`**              | `text`             |
# **`position`**          | `integer`          |
# **`title`**             | `string`           | `not null`
# **`url`**               | `string`           | `not null`
# **`created_at`**        | `datetime`         | `not null`
# **`updated_at`**        | `datetime`         | `not null`
# **`library_group_id`**  | `bigint`           | `default(1), not null`
#
FactoryBot.define do
  factory :news_feed do |f|
    f.sequence(:title) { |n| "news_feed_#{n}" }
    f.sequence(:url) { |n| "http://www.example.com/feed/#{n}" }
  end
end
