class AddRemoveReasonIdToItem < ActiveRecord::Migration
  def change
    add_column :items, :remove_reason_id, :integer
    add_index :items, :remove_reason_id
  end
end
