require 'rails_helper'

RSpec.describe ManifestationCustomProperty, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end

# ## Schema Information
#
# Table name: `manifestation_custom_properties`
#
# ### Columns
#
# Name                        | Type               | Attributes
# --------------------------- | ------------------ | ---------------------------
# **`id`**                    | `bigint`           | `not null, primary key`
# **`display_name(表示名)`**  | `text`             | `not null`
# **`name(ラベル名)`**        | `string`           | `not null`
# **`note(備考)`**            | `text`             |
# **`position`**              | `integer`          | `default(1), not null`
# **`created_at`**            | `datetime`         | `not null`
# **`updated_at`**            | `datetime`         | `not null`
#
# ### Indexes
#
# * `index_manifestation_custom_properties_on_lower_name` (_unique_):
#     * **`lower((name)::text)`**
#
