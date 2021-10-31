class AgentImportFileJob < ApplicationJob
  queue_as :enju_leaf

  def perform(agent_import_file)
    agent_import_file.import_start
  end
end
