class AddUniqueIndexToItemsOnItemIdentifier < ActiveRecord::Migration[6.1]
  def change
    remove_index :items, :item_identifier
    add_index :items, :item_identifier, unique: true, where: "item_identifier != '' AND item_identifier IS NOT NULL"
  end
end
