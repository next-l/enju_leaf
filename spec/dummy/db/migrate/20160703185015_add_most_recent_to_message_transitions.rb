class AddMostRecentToMessageTransitions < ActiveRecord::Migration
  def up
    add_column :message_transitions, :most_recent, :boolean, null: true
  end

  def down
    remove_column :message_transitions, :most_recent
  end
end
