require 'rails_helper'

RSpec.describe Periodical, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end

# ## Schema Information
#
# Table name: `periodicals`
#
# ### Columns
#
# Name                    | Type               | Attributes
# ----------------------- | ------------------ | ---------------------------
# **`id`**                | `bigint`           | `not null, primary key`
# **`original_title`**    | `text`             | `not null`
# **`created_at`**        | `datetime`         | `not null`
# **`updated_at`**        | `datetime`         | `not null`
# **`frequency_id`**      | `bigint`           | `not null`
# **`manifestation_id`**  | `bigint`           | `not null`
#
# ### Indexes
#
# * `index_periodicals_on_frequency_id`:
#     * **`frequency_id`**
# * `index_periodicals_on_manifestation_id`:
#     * **`manifestation_id`**
#
# ### Foreign Keys
#
# * `fk_rails_...`:
#     * **`frequency_id => frequencies.id`**
# * `fk_rails_...`:
#     * **`manifestation_id => manifestations.id`**
#
