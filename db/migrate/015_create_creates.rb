class CreateCreates < ActiveRecord::Migration
  def self.up
    create_table :creates do |t|
      t.references :patron, :null => false
      t.references :work, :null => false
      t.integer :position
      t.string :type
      t.timestamps
    end
    add_index :creates, :patron_id
    add_index :creates, :work_id
    add_index :creates, :type
  end

  def self.down
    drop_table :creates
  end
end
