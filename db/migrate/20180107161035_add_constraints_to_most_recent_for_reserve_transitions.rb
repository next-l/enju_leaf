class AddConstraintsToMostRecentForReserveTransitions < ActiveRecord::Migration[4.2]
  disable_ddl_transaction!

  def up
    add_index :reserve_transitions, [:reserve_id, :most_recent], unique: true, where: "most_recent", name: "index_reserve_transitions_parent_most_recent" # , algorithm: :concurrently
    change_column_null :reserve_transitions, :most_recent, false
  end

  def down
    remove_index :reserve_transitions, name: "index_reserve_transitions_parent_most_recent"
    change_column_null :reserve_transitions, :most_recent, true
  end
end
