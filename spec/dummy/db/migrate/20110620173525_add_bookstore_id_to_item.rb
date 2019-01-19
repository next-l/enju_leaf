class AddBookstoreIdToItem < ActiveRecord::Migration[5.2]
  def change
    add_reference :items, :bookstore, foreign_key: true
  end
end
