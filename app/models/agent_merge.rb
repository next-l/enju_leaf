class AgentMerge < ApplicationRecord
  belongs_to :agent
  belongs_to :agent_merge_list

  paginates_per 10
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
