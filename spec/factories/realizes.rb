FactoryBot.define do
  factory :realize do |f|
    f.expression_id {FactoryBot.create(:manifestation).id}
    f.agent_id {FactoryBot.create(:agent).id}
  end
end

# ## Schema Information
#
# Table name: `realizes`
#
# ### Columns
#
# Name                   | Type               | Attributes
# ---------------------- | ------------------ | ---------------------------
# **`id`**               | `bigint`           | `not null, primary key`
# **`position`**         | `integer`          |
# **`created_at`**       | `datetime`         | `not null`
# **`updated_at`**       | `datetime`         | `not null`
# **`agent_id`**         | `bigint`           | `not null`
# **`expression_id`**    | `bigint`           | `not null`
# **`realize_type_id`**  | `bigint`           |
#
# ### Indexes
#
# * `index_realizes_on_agent_id`:
#     * **`agent_id`**
# * `index_realizes_on_expression_id_and_agent_id` (_unique_):
#     * **`expression_id`**
#     * **`agent_id`**
#
