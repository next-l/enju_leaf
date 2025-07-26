FactoryBot.define do
  factory :shelf do |f|
    f.sequence(:name) {|n| "shelf_#{n}"}
    f.library_id {FactoryBot.create(:library).id}
  end
end

# ## Schema Information
#
# Table name: `shelves`
#
# ### Columns
#
# Name                | Type               | Attributes
# ------------------- | ------------------ | ---------------------------
# **`id`**            | `bigint`           | `not null, primary key`
# **`closed`**        | `boolean`          | `default(FALSE), not null`
# **`display_name`**  | `text`             |
# **`items_count`**   | `integer`          | `default(0), not null`
# **`name`**          | `string`           | `not null`
# **`note`**          | `text`             |
# **`position`**      | `integer`          |
# **`created_at`**    | `datetime`         | `not null`
# **`updated_at`**    | `datetime`         | `not null`
# **`library_id`**    | `bigint`           | `not null`
#
# ### Indexes
#
# * `index_shelves_on_library_id`:
#     * **`library_id`**
# * `index_shelves_on_lower_name` (_unique_):
#     * **`lower((name)::text)`**
#
