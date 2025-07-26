FactoryBot.define do
  factory :doi_record do
    sequence(:body) {|n| "body_#{n}"}
    association :manifestation
  end
end

# ## Schema Information
#
# Table name: `doi_records`
#
# ### Columns
#
# Name                    | Type               | Attributes
# ----------------------- | ------------------ | ---------------------------
# **`id`**                | `bigint`           | `not null, primary key`
# **`body`**              | `string`           | `not null`
# **`created_at`**        | `datetime`         | `not null`
# **`updated_at`**        | `datetime`         | `not null`
# **`manifestation_id`**  | `bigint`           | `not null`
#
# ### Indexes
#
# * `index_doi_records_on_lower_body_manifestation_id` (_unique_):
#     * **`lower((body)::text), manifestation_id`**
# * `index_doi_records_on_manifestation_id`:
#     * **`manifestation_id`**
#
# ### Foreign Keys
#
# * `fk_rails_...`:
#     * **`manifestation_id => manifestations.id`**
#
