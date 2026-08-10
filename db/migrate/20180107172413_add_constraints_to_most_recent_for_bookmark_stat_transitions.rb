class AddConstraintsToMostRecentForBookmarkStatTransitions < ActiveRecord::Migration[4.2]
  disable_ddl_transaction!

  def up
    add_index :bookmark_stat_transitions, [:bookmark_stat_id, :most_recent], unique: true, where: "most_recent", name: "index_bookmark_stat_transitions_parent_most_recent", if_not_exists: true #, algorithm: :concurrently
    change_column_null :bookmark_stat_transitions, :most_recent, false
  end

  def down
    remove_index :bookmark_stat_transitions, name: "index_bookmark_stat_transitions_parent_most_recent"
    change_column_null :bookmark_stat_transitions, :most_recent, true
  end
end
