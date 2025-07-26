require 'rails_helper'

describe Language do
  # pending "add some examples to (or delete) #{__FILE__}"

end

# ## Schema Information
#
# Table name: `languages`
#
# ### Columns
#
# Name                | Type               | Attributes
# ------------------- | ------------------ | ---------------------------
# **`id`**            | `bigint`           | `not null, primary key`
# **`display_name`**  | `text`             |
# **`iso_639_1`**     | `string`           |
# **`iso_639_2`**     | `string`           |
# **`iso_639_3`**     | `string`           |
# **`name`**          | `string`           | `not null`
# **`native_name`**   | `string`           |
# **`note`**          | `text`             |
# **`position`**      | `integer`          |
#
# ### Indexes
#
# * `index_languages_on_iso_639_1`:
#     * **`iso_639_1`**
# * `index_languages_on_iso_639_2`:
#     * **`iso_639_2`**
# * `index_languages_on_iso_639_3`:
#     * **`iso_639_3`**
# * `index_languages_on_lower_name` (_unique_):
#     * **`lower((name)::text)`**
#
