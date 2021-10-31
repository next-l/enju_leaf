class AddMostRecentToEventImportFileTransitions < ActiveRecord::Migration[4.2]
  def up
    add_column :event_import_file_transitions, :most_recent, :boolean, null: true
  end

  def down
    remove_column :event_import_file_transitions, :most_recent
  end
end
