class AgentImportFileTransition < ApplicationRecord
  belongs_to :agent_import_file, inverse_of: :agent_import_file_transitions
end

# == Schema Information
#
# Table name: agent_import_file_transitions
#
#  id                   :bigint           not null, primary key
#  metadata             :jsonb            not null
#  most_recent          :boolean          not null
#  sort_key             :integer
#  to_state             :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  agent_import_file_id :bigint
#
# Indexes
#
#  index_agent_import_file_transitions_on_agent_import_file_id  (agent_import_file_id)
#  index_agent_import_file_transitions_on_sort_key_and_file_id  (sort_key,agent_import_file_id) UNIQUE
#  index_agent_import_file_transitions_parent_most_recent       (agent_import_file_id,most_recent) UNIQUE WHERE most_recent
#
