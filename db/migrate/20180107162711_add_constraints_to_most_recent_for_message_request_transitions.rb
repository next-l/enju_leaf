class AddConstraintsToMostRecentForMessageRequestTransitions < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def up
    add_index :message_request_transitions, [:message_request_id, :most_recent], unique: true, where: "most_recent", name: "index_message_request_transitions_parent_most_recent" # , algorithm: :concurrently
    change_column_null :message_request_transitions, :most_recent, false
  end

  def down
    remove_index :message_request_transitions, name: "index_message_request_transitions_parent_most_recent"
    change_column_null :message_request_transitions, :most_recent, true
  end
end
