class CreateExemplifies < ActiveRecord::Migration
  def self.up
    create_table :exemplifies do |t|
      t.integer :manifestation_id, :null => false
      t.integer :item_id, :null => false
      t.string :type
      t.integer :position

      t.timestamps
    end
    add_index :exemplifies, :manifestation_id
    add_index :exemplifies, :item_id, :unique => true
    add_index :exemplifies, :type
  end

  def self.down
    drop_table :exemplifies
  end
end
