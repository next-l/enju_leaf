class CreateOwns < ActiveRecord::Migration
  def change
    create_table :owns do |t|
      t.references :patron, :null => false
      t.references :item, :null => false
      t.integer :position
      t.string :type
      t.timestamps
    end
    add_index :owns, :patron_id
    add_index :owns, :item_id
    add_index :owns, :type
  end
end
