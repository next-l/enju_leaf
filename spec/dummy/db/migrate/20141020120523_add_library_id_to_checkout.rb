class AddLibraryIdToCheckout < ActiveRecord::Migration
  def change
    add_column :checkouts, :library_id, :integer
    add_index :checkouts, :library_id
  end
end
