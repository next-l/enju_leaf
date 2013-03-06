class CreateDonates < ActiveRecord::Migration
  def change
    create_table :donates do |t|
      t.integer :patron_id, :null => false
      t.integer :item_id, :null => false

      t.timestamps
    end
    add_index :donates, :patron_id
    add_index :donates, :item_id
  end
end
