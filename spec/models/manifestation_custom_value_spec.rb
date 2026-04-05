require 'rails_helper'

RSpec.describe ManifestationCustomValue, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end

# ## Schema Information
#
# Table name: `manifestation_custom_values`
#
# ### Columns
#
# Name                                    | Type               | Attributes
# --------------------------------------- | ------------------ | ---------------------------
# **`id`**                                | `bigint`           | `not null, primary key`
# **`value`**                             | `text`             |
# **`created_at`**                        | `datetime`         | `not null`
# **`updated_at`**                        | `datetime`         | `not null`
# **`manifestation_custom_property_id`**  | `bigint`           | `not null`
# **`manifestation_id`**                  | `bigint`           | `not null`
#
# ### Indexes
#
# * `index_manifestation_custom_values_on_custom_property_id`:
#     * **`manifestation_custom_property_id`**
# * `index_manifestation_custom_values_on_manifestation_id`:
#     * **`manifestation_id`**
# * `index_manifestation_custom_values_on_property_manifestation` (_unique_):
#     * **`manifestation_custom_property_id`**
#     * **`manifestation_id`**
#
# ### Foreign Keys
#
# * `fk_rails_...`:
#     * **`manifestation_custom_property_id => manifestation_custom_properties.id`**
# * `fk_rails_...`:
#     * **`manifestation_id => manifestations.id`**
#
