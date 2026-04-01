FactoryBot.define do
  factory :budget_type do |f|
    f.sequence(:name) {|n| "budget_type_#{n}"}
  end
end

# ## Schema Information
#
# Table name: `budget_types`
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
# * `index_budget_types_on_lower_name` (_unique_):
#     * **`lower((name)::text)`**
#
