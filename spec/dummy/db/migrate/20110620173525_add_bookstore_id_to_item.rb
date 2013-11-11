class AddBookstoreIdToItem < ActiveRecord::Migration
  def self.up
    add_column :items, :bookstore_id, :integer
    add_index :items, :bookstore_id
  end

  def self.down
    remove_index :items, :bookstore_id
    remove_column :items, :bookstore_id
  end
end
