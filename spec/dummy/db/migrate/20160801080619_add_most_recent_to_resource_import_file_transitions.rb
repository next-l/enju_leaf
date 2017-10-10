class AddMostRecentToResourceImportFileTransitions < ActiveRecord::Migration[5.1]
  def up
    add_column :resource_import_file_transitions, :most_recent, :boolean, null: true
  end

  def down
    remove_column :resource_import_file_transitions, :most_recent
  end
end
