FactoryBot.define do
  factory :subject_heading_type do |f|
    f.sequence(:name) {|n| "subject_heading_type_#{n}"}
  end
end

# ## Schema Information
#
# Table name: `subject_heading_types`
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
# * `index_subject_heading_types_on_lower_name` (_unique_):
#     * **`lower((name)::text)`**
#
