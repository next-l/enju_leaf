class AddAgentImportIdToAgentImportFile < ActiveRecord::Migration
  def change
    add_column :agent_import_files, :agent_import_id, :string
    rename_column :agent_import_files, :agent_import_file_size, :agent_import_size
    add_index :agent_import_files, :agent_import_id
  end
end
