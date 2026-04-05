require 'rails_helper'

describe Event do
  fixtures :events

  it "should set_all_day" do
    event = events(:event_00001)
    event.all_day = true
    event.set_all_day
    expect(event.all_day).to be_truthy
  end

  it "should set all_day and beginning_of_day" do
    event = events(:event_00008)
    event.all_day = true
    event.set_all_day
    expect(event.start_at).to eq event.end_at.beginning_of_day
  end

  it "should export events" do
    lines = Event.export
    CSV.parse(lines, col_sep: "\t")
    expect(lines).not_to be_empty
    expect(lines.split(/\n/).size).to eq Event.all.count + 1
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
