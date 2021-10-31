class AddItemIdentifierToInventory < ActiveRecord::Migration[5.2]
  def change
    add_column :inventories, :item_identifier, :string
    add_index :inventories, :item_identifier
  end
end
