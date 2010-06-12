class CreateOwns < ActiveRecord::Migration
  def self.up
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

  def self.down
    drop_table :owns
  end
end
