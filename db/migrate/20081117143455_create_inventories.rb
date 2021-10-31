class CreateInventories < ActiveRecord::Migration[4.2]
  def self.up
    create_table :inventories do |t|
      t.references :item, index: true
      t.references :inventory_file, index: true
      t.text :note

      t.timestamps
    end
  end

  def self.down
    drop_table :inventories
  end
end
