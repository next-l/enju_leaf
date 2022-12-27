class CreateInventoryFiles < ActiveRecord::Migration[4.2]
  def self.up
    create_table :inventory_files do |t|
      t.references :user, index: true
      t.text :note

      t.timestamps
    end
  end

  def self.down
    drop_table :inventory_files
  end
end
