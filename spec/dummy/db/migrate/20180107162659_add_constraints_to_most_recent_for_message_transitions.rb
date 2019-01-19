class AddConstraintsToMostRecentForMessageTransitions < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def up
    add_index :message_transitions, [:message_id, :most_recent], unique: true, where: "most_recent", name: "index_message_transitions_parent_most_recent" # , algorithm: :concurrently
    change_column_null :message_transitions, :most_recent, false
  end

  def down
    remove_index :message_transitions, name: "index_message_transitions_parent_most_recent"
    change_column_null :message_transitions, :most_recent, true
  end
end
