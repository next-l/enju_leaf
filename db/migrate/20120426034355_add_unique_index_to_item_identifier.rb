class AddUniqueIndexToItemIdentifier < ActiveRecord::Migration
  def up
    remove_index :items, :item_identifier
    add_index :items, :item_identifier, :unique => true
  end

  def down
    remove_index :items, :item_identifier
    add_index :items, :item_identifier
  end
end
