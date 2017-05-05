class AddMostRecentToReserveTransitions < ActiveRecord::Migration
  def up
    add_column :reserve_transitions, :most_recent, :boolean, null: true
  end

  def down
    remove_column :reserve_transitions, :most_recent
  end
end
