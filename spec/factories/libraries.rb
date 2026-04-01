FactoryBot.define do
  factory :library do |f|
    f.sequence(:name) {|n| "library#{n}"}
    f.sequence(:short_display_name) {|n| "library_#{n}"}
    f.library_group_id {LibraryGroup.first.id}
  end
end

FactoryBot.define do
  factory :invalid_library, class: Library do |f|
    f.library_group_id {LibraryGroup.first.id}
  end
end

# ## Schema Information
#
# Table name: `libraries`
#
# ### Columns
#
# Name                         | Type               | Attributes
# ---------------------------- | ------------------ | ---------------------------
# **`id`**                     | `bigint`           | `not null, primary key`
# **`call_number_delimiter`**  | `string`           | `default("|"), not null`
# **`call_number_rows`**       | `integer`          | `default(1), not null`
# **`display_name`**           | `text`             |
# **`fax_number`**             | `string`           |
# **`isil`**                   | `string`           |
# **`latitude`**               | `float`            |
# **`locality`**               | `text`             |
# **`longitude`**              | `float`            |
# **`name`**                   | `string`           | `not null`
# **`note`**                   | `text`             |
# **`opening_hour`**           | `text`             |
# **`position`**               | `integer`          |
# **`region`**                 | `text`             |
# **`short_display_name`**     | `string`           | `not null`
# **`street`**                 | `text`             |
# **`telephone_number_1`**     | `string`           |
# **`telephone_number_2`**     | `string`           |
# **`users_count`**            | `integer`          | `default(0), not null`
# **`zip_code`**               | `string`           |
# **`created_at`**             | `datetime`         | `not null`
# **`updated_at`**             | `datetime`         | `not null`
# **`country_id`**             | `bigint`           |
# **`library_group_id`**       | `bigint`           | `not null`
#
# ### Indexes
#
# * `index_libraries_on_isil` (_unique_ _where_ (((isil)::text <> ''::text) AND (isil IS NOT NULL))):
#     * **`isil`**
# * `index_libraries_on_library_group_id`:
#     * **`library_group_id`**
# * `index_libraries_on_lower_name` (_unique_):
#     * **`lower((name)::text)`**
# * `index_libraries_on_name` (_unique_):
#     * **`name`**
#
# ### Foreign Keys
#
# * `fk_rails_...`:
#     * **`library_group_id => library_groups.id`**
#
