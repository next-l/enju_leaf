FactoryBot.define do
  factory :identifier_type do |f|
    f.sequence(:name) {|n| "identifier_type_#{n}"}
  end
end

# ## Schema Information
#
# Table name: `identifier_types`
#
# ### Columns
#
# Name                | Type               | Attributes
# ------------------- | ------------------ | ---------------------------
# **`id`**            | `bigint`           | `not null, primary key`
# **`display_name`**  | `text`             |
# **`name`**          | `string`           | `not null`
# **`note`**          | `text`             |
# **`position`**      | `integer`          |
# **`created_at`**    | `datetime`         | `not null`
# **`updated_at`**    | `datetime`         | `not null`
#
# ### Indexes
#
# * `index_identifier_types_on_lower_name` (_unique_):
#     * **`lower((name)::text)`**
#
