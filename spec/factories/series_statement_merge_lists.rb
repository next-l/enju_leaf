# ## Schema Information
#
# Table name: `series_statement_merge_lists`
# Database name: `primary`
#
# ### Columns
#
# Name              | Type               | Attributes
# ----------------- | ------------------ | ---------------------------
# **`id`**          | `bigint`           | `not null, primary key`
# **`title`**       | `string`           | `not null`
# **`created_at`**  | `datetime`         | `not null`
# **`updated_at`**  | `datetime`         | `not null`
#
FactoryBot.define do
  factory :series_statement_merge_list do |f|
    f.sequence(:title) { |n| "series_statement_merge_list_#{n}" }
  end
end
