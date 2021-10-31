class AddConstraintsToMostRecentForEventExportFileTransitions < ActiveRecord::Migration[4.2]
  disable_ddl_transaction!

  def up
    add_index :event_export_file_transitions, [:event_export_file_id, :most_recent], unique: true, where: "most_recent", name: "index_event_export_file_transitions_parent_most_recent" #, algorithm: :concurrently
    change_column_null :event_export_file_transitions, :most_recent, false
  end

  def down
    remove_index :event_export_file_transitions, name: "index_event_export_file_transitions_parent_most_recent"
    change_column_null :event_export_file_transitions, :most_recent, true
  end
end
