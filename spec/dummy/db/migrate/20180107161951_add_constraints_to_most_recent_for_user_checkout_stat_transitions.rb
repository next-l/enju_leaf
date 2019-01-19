class AddConstraintsToMostRecentForUserCheckoutStatTransitions < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def up
    add_index :user_checkout_stat_transitions, [:user_checkout_stat_id, :most_recent], unique: true, where: "most_recent", name: "index_user_checkout_stat_transitions_parent_most_recent" # , algorithm: :concurrently
    change_column_null :user_checkout_stat_transitions, :most_recent, false
  end

  def down
    remove_index :user_checkout_stat_transitions, name: "index_user_checkout_stat_transitions_parent_most_recent"
    change_column_null :user_checkout_stat_transitions, :most_recent, true
  end
end
