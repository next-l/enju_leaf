FactoryBot.define do
  factory :agent_merge do |f|
    f.agent_merge_list_id {FactoryBot.create(:agent_merge_list).id}
    f.agent_id {FactoryBot.create(:agent).id}
  end
end

# == Schema Information
#
# Table name: agent_merges
#
#  id                  :bigint           not null, primary key
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  agent_id            :bigint           not null
#  agent_merge_list_id :bigint           not null
#
# Indexes
#
#  index_agent_merges_on_agent_id             (agent_id)
#  index_agent_merges_on_agent_merge_list_id  (agent_merge_list_id)
#
