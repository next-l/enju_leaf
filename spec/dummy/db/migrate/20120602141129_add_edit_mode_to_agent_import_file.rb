class AddEditModeToAgentImportFile < ActiveRecord::Migration
  def change
    add_column :agent_import_files, :edit_mode, :string
  end
end
