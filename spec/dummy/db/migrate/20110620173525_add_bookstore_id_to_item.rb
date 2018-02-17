class AddBookstoreIdToItem < ActiveRecord::Migration[5.1]
  def change
    add_reference :items, :bookstore, foreign_key: true, type: :uuid
  end
end
