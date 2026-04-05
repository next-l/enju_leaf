class RemoveParentIdFromAgentImportFiles < ActiveRecord::Migration[7.2]
  def change
    remove_column :agent_import_files, :parent_id, :bigint
    remove_column :event_import_files, :parent_id, :bigint
    remove_column :resource_import_files, :parent_id, :bigint
  end
end
