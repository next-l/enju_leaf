class AddCurrentShelfNameToInventory < ActiveRecord::Migration[5.2]
  def up
    add_column :inventories, :current_shelf_name, :string, if_not_exists: true
    add_index :inventories, :current_shelf_name, if_not_exists: true
  end

  def down
    remove_column :inventories, :current_shelf_name
  end
end
