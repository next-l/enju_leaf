class CreateEnjuTrunkInventoryInventoryManages < ActiveRecord::Migration
  def change
    create_table :inventory_manages do |t|
      t.string :display_name
      t.string :manifestation_type_ids
      t.string :shelf_group_ids
      t.text :notification_dest
      t.integer :state, :null => false, :default => 0
      t.timestamp :finished_at

      t.timestamps
    end
  end
end
