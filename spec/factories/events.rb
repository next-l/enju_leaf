FactoryBot.define do
  factory :event do |f|
    f.sequence(:name) {|n| "event_#{n}"}
    f.start_at {Time.zone.now}
    f.end_at {1.hour.from_now}
    f.library_id {FactoryBot.create(:library).id}
    f.event_category_id {FactoryBot.create(:event_category).id}
  end
end

# ## Schema Information
#
# Table name: `events`
#
# ### Columns
#
# Name                     | Type               | Attributes
# ------------------------ | ------------------ | ---------------------------
# **`id`**                 | `bigint`           | `not null, primary key`
# **`all_day`**            | `boolean`          | `default(FALSE), not null`
# **`display_name`**       | `text`             |
# **`end_at`**             | `datetime`         |
# **`name`**               | `string`           | `not null`
# **`note`**               | `text`             |
# **`start_at`**           | `datetime`         |
# **`created_at`**         | `datetime`         | `not null`
# **`updated_at`**         | `datetime`         | `not null`
# **`event_category_id`**  | `bigint`           | `not null`
# **`library_id`**         | `bigint`           | `not null`
# **`place_id`**           | `bigint`           |
#
# ### Indexes
#
# * `index_events_on_event_category_id`:
#     * **`event_category_id`**
# * `index_events_on_library_id`:
#     * **`library_id`**
# * `index_events_on_place_id`:
#     * **`place_id`**
#
# ### Foreign Keys
#
# * `fk_rails_...`:
#     * **`event_category_id => event_categories.id`**
#
