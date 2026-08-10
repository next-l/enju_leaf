class AddItemIdentifierToInventory < ActiveRecord::Migration[5.2]
  def up
    add_column :inventories, :item_identifier, :string, if_not_exists: true
    add_index :inventories, :item_identifier
  end

  def down
    remove_column :inventories, :item_identifier
  end
end
