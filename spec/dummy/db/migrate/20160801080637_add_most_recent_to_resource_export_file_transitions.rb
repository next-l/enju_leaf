class AddMostRecentToResourceExportFileTransitions < ActiveRecord::Migration
  def up
    add_column :resource_export_file_transitions, :most_recent, :boolean, null: true
  end

  def down
    remove_column :resource_export_file_transitions, :most_recent
  end
end
