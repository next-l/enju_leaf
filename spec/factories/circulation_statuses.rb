FactoryBot.define do
  factory :circulation_status do |f|
    f.sequence(:name) {|n| "circulation_status_#{n}"}
  end
end

# ## Schema Information
#
# Table name: `circulation_statuses`
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
# * `index_circulation_statuses_on_lower_name` (_unique_):
#     * **`lower((name)::text)`**
#
