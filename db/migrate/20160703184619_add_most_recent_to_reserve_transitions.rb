class AddMostRecentToReserveTransitions < ActiveRecord::Migration[4.2]
  def up
    add_column :reserve_transitions, :most_recent, :boolean, null: true
  end

  def down
    remove_column :reserve_transitions, :most_recent
  end
end
