class CreateInventoryFiles < ActiveRecord::Migration
  def self.up
    create_table :inventory_files do |t|
      t.string :filename
      t.string :content_type
      t.integer :size
      t.string :file_hash
      t.integer :user_id
      t.text :note

      t.timestamps
    end
    add_index :inventory_files, :user_id
    add_index :inventory_files, :file_hash
  end

  def self.down
    drop_table :inventory_files
  end
end
