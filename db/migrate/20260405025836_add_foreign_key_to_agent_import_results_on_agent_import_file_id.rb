class AddForeignKeyToAgentImportResultsOnAgentImportFileId < ActiveRecord::Migration[7.2]
  def change
    AgentImportResult.find_each do |i|
      i.destroy unless i.agent_import_file
    end
    EventImportResult.find_each do |i|
      i.destroy unless i.event_import_file
    end
    ResourceImportResult.find_each do |i|
      i.destroy unless i.resource_import_file
    end
    UserImportResult.find_each do |i|
      i.destroy unless i.user_import_file
    end

    add_foreign_key :agent_import_results, :agent_import_files
    add_foreign_key :event_import_results, :event_import_files
    add_foreign_key :resource_import_results, :resource_import_files
    add_foreign_key :user_import_results, :user_import_files
  end
end
