class AddUniqueIndexToAcceptsOnItemId < ActiveRecord::Migration[6.1]
  def change
    remove_index :accepts, :item_id
    add_index :accepts, :item_id, unique: true

    remove_index :withdraws, :item_id
    add_index :withdraws, :item_id, unique: true
  end
end
