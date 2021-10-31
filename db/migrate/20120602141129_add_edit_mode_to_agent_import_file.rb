class AddEditModeToAgentImportFile < ActiveRecord::Migration[4.2]
  def change
    add_column :agent_import_files, :edit_mode, :string
  end
end
