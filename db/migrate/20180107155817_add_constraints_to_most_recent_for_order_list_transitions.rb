class AddConstraintsToMostRecentForOrderListTransitions < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def up
    add_index :order_list_transitions, [:order_list_id, :most_recent], unique: true, where: "most_recent", name: "index_order_list_transitions_parent_most_recent" #, algorithm: :concurrently
    change_column_null :order_list_transitions, :most_recent, false
  end

  def down
    remove_index :order_list_transitions, name: "index_order_list_transitions_parent_most_recent"
    change_column_null :order_list_transitions, :most_recent, true
  end
end
