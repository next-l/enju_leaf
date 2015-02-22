class CreateCheckedItems < ActiveRecord::Migration
  def self.up
    create_table :checked_items do |t|
      t.integer :item_id, :null => false
      t.integer :basket_id, :null => false
      t.datetime :due_date, :null => false

      t.timestamps
    end
    add_index :checked_items, :item_id
    add_index :checked_items, :basket_id
  end

  def self.down
    drop_table :checked_items
  end
end
