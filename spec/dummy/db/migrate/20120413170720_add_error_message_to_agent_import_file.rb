class AddErrorMessageToAgentImportFile < ActiveRecord::Migration
  def change
    add_column :agent_import_files, :error_message, :text
  end
end
