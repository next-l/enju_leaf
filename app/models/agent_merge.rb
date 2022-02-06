class AgentMerge < ApplicationRecord
  belongs_to :agent
  belongs_to :agent_merge_list

  paginates_per 10
end

# == Schema Information
#
# Table name: agent_merges
#
#  id                  :integer          not null, primary key
#  agent_id            :integer          not null
#  agent_merge_list_id :integer          not null
#  created_at          :datetime
#  updated_at          :datetime
#
