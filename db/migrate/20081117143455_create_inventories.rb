class CreateInventories < ActiveRecord::Migration[4.2]
  def up
    create_table :inventories, if_not_exists: true do |t|
      t.references :item, index: true
      t.references :inventory_file, index: true
      t.text :note

      t.timestamps
    end
  end

  def down
    drop_table :inventories
  end
end
