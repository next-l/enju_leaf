require 'rails_helper'

RSpec.describe PeriodicalAndManifestation, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end

# ## Schema Information
#
# Table name: `periodical_and_manifestations`
#
# ### Columns
#
# Name                    | Type               | Attributes
# ----------------------- | ------------------ | ---------------------------
# **`id`**                | `bigint`           | `not null, primary key`
# **`created_at`**        | `datetime`         | `not null`
# **`updated_at`**        | `datetime`         | `not null`
# **`manifestation_id`**  | `bigint`           | `not null`
# **`periodical_id`**     | `bigint`           | `not null`
#
# ### Indexes
#
# * `index_periodical_and_manifestations_on_manifestation_id`:
#     * **`manifestation_id`**
# * `index_periodical_and_manifestations_on_periodical_id`:
#     * **`periodical_id`**
#
# ### Foreign Keys
#
# * `fk_rails_...`:
#     * **`manifestation_id => manifestations.id`**
# * `fk_rails_...`:
#     * **`periodical_id => periodicals.id`**
#
