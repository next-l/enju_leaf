FactoryBot.define do
  factory :own do |f|
    f.item_id {FactoryBot.create(:item).id}
    f.agent_id {FactoryBot.create(:agent).id}
  end
end

# == Schema Information
#
# Table name: owns
#
#  id         :bigint           not null, primary key
#  position   :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  agent_id   :bigint           not null
#  item_id    :bigint           not null
#
# Indexes
#
#  index_owns_on_agent_id              (agent_id)
#  index_owns_on_item_id_and_agent_id  (item_id,agent_id) UNIQUE
#
