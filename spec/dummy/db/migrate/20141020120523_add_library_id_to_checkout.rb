class AddLibraryIdToCheckout < ActiveRecord::Migration[4.2]
  def change
    add_column :checkouts, :library_id, :integer
    add_index :checkouts, :library_id
  end
end
