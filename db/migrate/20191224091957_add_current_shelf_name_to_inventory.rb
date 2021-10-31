class AddCurrentShelfNameToInventory < ActiveRecord::Migration[5.2]
  def change
    add_column :inventories, :current_shelf_name, :string
    add_index :inventories, :current_shelf_name
  end
end
