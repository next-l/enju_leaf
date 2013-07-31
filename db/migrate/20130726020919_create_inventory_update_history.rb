class CreateInventoryUpdateHistory < ActiveRecord::Migration
  def change
    create_table :inventory_update_histories do |t|
      t.integer :inventory_manage_id, :null => false
      t.string :item_identifier, :null => false
      t.text :before_item 
      t.text :diffparam

      t.timestamps
    end
    add_index :inventory_update_histories, [:inventory_manage_id, :item_identifier], :name => "inventory_update_histories_index_1"
  end
end
