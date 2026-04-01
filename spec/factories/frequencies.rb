FactoryBot.define do
  factory :frequency do |f|
    f.sequence(:name) {|n| "frequency_#{n}"}
  end
end

# ## Schema Information
#
# Table name: `frequencies`
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
# * `index_frequencies_on_lower_name` (_unique_):
#     * **`lower((name)::text)`**
#
