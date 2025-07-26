class AddBookstoreIdToItem < ActiveRecord::Migration[4.2]
  def up
    add_column :items, :bookstore_id, :integer
    add_index :items, :bookstore_id
  end

  def down
    remove_index :items, :bookstore_id
    remove_column :items, :bookstore_id
  end
end
