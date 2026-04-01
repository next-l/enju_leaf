require 'rails_helper'

describe SeriesStatement do
  fixtures :all

  it "should create manifestation" do
    series_statement = FactoryBot.create(:series_statement)
    series_statement.root_manifestation.should be_nil
  end
end

# ## Schema Information
#
# Table name: `series_statements`
#
# ### Columns
#
# Name                                      | Type               | Attributes
# ----------------------------------------- | ------------------ | ---------------------------
# **`id`**                                  | `bigint`           | `not null, primary key`
# **`creator_string`**                      | `text`             |
# **`note`**                                | `text`             |
# **`numbering`**                           | `text`             |
# **`numbering_subseries`**                 | `text`             |
# **`original_title`**                      | `text`             |
# **`position`**                            | `integer`          |
# **`series_master`**                       | `boolean`          |
# **`series_statement_identifier`**         | `string`           |
# **`title_alternative`**                   | `text`             |
# **`title_subseries`**                     | `text`             |
# **`title_subseries_transcription`**       | `text`             |
# **`title_transcription`**                 | `text`             |
# **`volume_number_string`**                | `text`             |
# **`volume_number_transcription_string`**  | `text`             |
# **`created_at`**                          | `datetime`         | `not null`
# **`updated_at`**                          | `datetime`         | `not null`
# **`manifestation_id`**                    | `bigint`           |
# **`root_manifestation_id`**               | `bigint`           |
#
# ### Indexes
#
# * `index_series_statements_on_manifestation_id`:
#     * **`manifestation_id`**
# * `index_series_statements_on_root_manifestation_id`:
#     * **`root_manifestation_id`**
# * `index_series_statements_on_series_statement_identifier`:
#     * **`series_statement_identifier`**
#
