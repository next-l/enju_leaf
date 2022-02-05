class AgentMergeList < ApplicationRecord
  has_many :agent_merges, dependent: :destroy
  has_many :agents, through: :agent_merges
  validates_presence_of :title

  paginates_per 10

  def merge_agents(selected_agent)
    agents.each do |agent|
      Create.where(agent_id: selected_agent.id).update_all(agent_id: agent.id)
      Produce.where(agent_id: selected_agent.id).update_all(agent_id: agent.id)
      Own.where(agent_id: selected_agent.id).update_all(agent_id: agent.id)
      Donate.where(agent_id: selected_agent.id).update_all(agent_id: agent.id)
      agent.destroy unless agent == selected_agent
    end
  end
end

# == Schema Information
#
# Table name: agent_merge_lists
#
#  id         :integer          not null, primary key
#  title      :string
#  created_at :datetime
#  updated_at :datetime
#
