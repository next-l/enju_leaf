class AgentImportResult < ApplicationRecord
  default_scope { order('agent_import_results.id') }
  scope :file_id, proc{|file_id| where(agent_import_file_id: file_id)}
  scope :failed, -> { where(agent_id: nil) }

  belongs_to :agent_import_file
  belongs_to :agent, optional: true
end

# == Schema Information
#
# Table name: agent_import_results
#
#  id                   :bigint           not null, primary key
#  agent_import_file_id :integer
#  agent_id             :bigint
#  body                 :text
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
