class AddMostRecentToImportRequestTransitions < ActiveRecord::Migration
  def up
    add_column :import_request_transitions, :most_recent, :boolean, null: true
  end

  def down
    remove_column :import_request_transitions, :most_recent
  end
end
