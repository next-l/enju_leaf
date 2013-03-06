class CreateCreates < ActiveRecord::Migration
  def change
    create_table :creates do |t|
      t.references :patron, :null => false
      t.references :work, :null => false
      t.integer :position
      t.timestamps
    end
    add_index :creates, :patron_id
    add_index :creates, :work_id
  end
end
