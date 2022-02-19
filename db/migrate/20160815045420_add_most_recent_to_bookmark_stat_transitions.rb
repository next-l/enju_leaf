class AddMostRecentToBookmarkStatTransitions < ActiveRecord::Migration[4.2]
  def up
    add_column :bookmark_stat_transitions, :most_recent, :boolean, null: true
  end

  def down
    remove_column :bookmark_stat_transitions, :most_recent
  end
end
