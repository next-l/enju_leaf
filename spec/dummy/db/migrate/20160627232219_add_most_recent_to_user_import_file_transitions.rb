class AddMostRecentToUserImportFileTransitions < ActiveRecord::Migration[4.2]
  def up
    add_column :user_import_file_transitions, :most_recent, :boolean, null: true
  end

  def down
    remove_column :user_import_file_transitions, :most_recent
  end
end
