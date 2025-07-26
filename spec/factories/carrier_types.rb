FactoryBot.define do
  factory :carrier_type do |f|
    f.sequence(:name) {|n| "carrier_type_#{n}"}
  end
end

# ## Schema Information
#
# Table name: `carrier_types`
#
# ### Columns
#
# Name                           | Type               | Attributes
# ------------------------------ | ------------------ | ---------------------------
# **`id`**                       | `bigint`           | `not null, primary key`
# **`attachment_content_type`**  | `string`           |
# **`attachment_file_name`**     | `string`           |
# **`attachment_file_size`**     | `bigint`           |
# **`attachment_updated_at`**    | `datetime`         |
# **`display_name`**             | `text`             |
# **`name`**                     | `string`           | `not null`
# **`note`**                     | `text`             |
# **`position`**                 | `integer`          |
# **`created_at`**               | `datetime`         | `not null`
# **`updated_at`**               | `datetime`         | `not null`
#
# ### Indexes
#
# * `index_carrier_types_on_lower_name` (_unique_):
#     * **`lower((name)::text)`**
#
