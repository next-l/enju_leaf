FactoryBot.define do
  factory :bookstore do |f|
    f.sequence(:name) {|n| "bookstore_#{n}"}
  end
end

# ## Schema Information
#
# Table name: `bookstores`
#
# ### Columns
#
# Name                    | Type               | Attributes
# ----------------------- | ------------------ | ---------------------------
# **`id`**                | `bigint`           | `not null, primary key`
# **`address`**           | `text`             |
# **`fax_number`**        | `string`           |
# **`name`**              | `text`             | `not null`
# **`note`**              | `text`             |
# **`position`**          | `integer`          |
# **`telephone_number`**  | `string`           |
# **`url`**               | `string`           |
# **`zip_code`**          | `string`           |
# **`created_at`**        | `datetime`         | `not null`
# **`updated_at`**        | `datetime`         | `not null`
#
