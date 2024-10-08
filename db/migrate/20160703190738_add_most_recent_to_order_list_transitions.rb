class AddMostRecentToOrderListTransitions < ActiveRecord::Migration[6.1]
  def up
    add_column :order_list_transitions, :most_recent, :boolean, null: true, if_not_exists: true
  end

  def down
    remove_column :order_list_transitions, :most_recent
  end
end
