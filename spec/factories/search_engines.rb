FactoryBot.define do
  factory :search_engine do |f|
    f.sequence(:name) {|n| "search_engine_#{n}"}
    f.sequence(:url) {|n| "http://search-engine-#{n}.example.jp"}
    f.sequence(:base_url) {|n| "http://search-engine-#{n}.example.jp"}
    f.query_param { 'q' }
    f.http_method { 'get' }
  end
end

# ## Schema Information
#
# Table name: `search_engines`
#
# ### Columns
#
# Name                    | Type               | Attributes
# ----------------------- | ------------------ | ---------------------------
# **`id`**                | `bigint`           | `not null, primary key`
# **`additional_param`**  | `text`             |
# **`base_url`**          | `text`             | `not null`
# **`display_name`**      | `text`             |
# **`http_method`**       | `text`             | `not null`
# **`name`**              | `string`           | `not null`
# **`note`**              | `text`             |
# **`position`**          | `integer`          |
# **`query_param`**       | `text`             | `not null`
# **`url`**               | `string`           | `not null`
# **`created_at`**        | `datetime`         | `not null`
# **`updated_at`**        | `datetime`         | `not null`
#
