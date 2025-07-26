FactoryBot.define do
  factory :donate do |f|
    f.item_id {FactoryBot.create(:item).id}
    f.agent_id {FactoryBot.create(:agent).id}
  end
end

# == Schema Information
#
# Table name: donates
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  agent_id   :bigint           not null
#  item_id    :bigint           not null
#
# Indexes
#
#  index_donates_on_agent_id  (agent_id)
#  index_donates_on_item_id   (item_id)
#
