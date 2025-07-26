require 'rails_helper'

describe Country do
  # pending "add some examples to (or delete) #{__FILE__}"

end

# ## Schema Information
#
# Table name: `countries`
#
# ### Columns
#
# Name                | Type               | Attributes
# ------------------- | ------------------ | ---------------------------
# **`id`**            | `bigint`           | `not null, primary key`
# **`alpha_2`**       | `string`           |
# **`alpha_3`**       | `string`           |
# **`display_name`**  | `text`             |
# **`name`**          | `string`           | `not null`
# **`note`**          | `text`             |
# **`numeric_3`**     | `string`           |
# **`position`**      | `integer`          |
#
# ### Indexes
#
# * `index_countries_on_alpha_2`:
#     * **`alpha_2`**
# * `index_countries_on_alpha_3`:
#     * **`alpha_3`**
# * `index_countries_on_lower_name` (_unique_):
#     * **`lower((name)::text)`**
# * `index_countries_on_numeric_3`:
#     * **`numeric_3`**
#
