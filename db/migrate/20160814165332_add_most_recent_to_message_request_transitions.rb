class AddMostRecentToMessageRequestTransitions < ActiveRecord::Migration[5.2]
  def up
    add_column :message_request_transitions, :most_recent, :boolean, null: true
  end

  def down
    remove_column :message_request_transitions, :most_recent
  end
end
