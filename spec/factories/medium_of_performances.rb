FactoryBot.define do
  factory :medium_of_performance do |f|
    f.sequence(:name) {|n| "medium_of_performance_#{n}"}
  end
end

# ## Schema Information
#
# Table name: `medium_of_performances`
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
# * `index_medium_of_performances_on_lower_name` (_unique_):
#     * **`lower((name)::text)`**
#
