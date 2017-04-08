class AddLibraryIdToCheckout < ActiveRecord::Migration[5.0]
  def change
    add_column :checkouts, :library_id, :integer
    add_index :checkouts, :library_id
  end
end
