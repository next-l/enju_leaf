class AddLibrarianIdToReserves < ActiveRecord::Migration
  def change
    add_column :reserves, :librarian_id, :integer
  end
end
