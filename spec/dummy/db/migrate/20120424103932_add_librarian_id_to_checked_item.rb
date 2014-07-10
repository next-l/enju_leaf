class AddLibrarianIdToCheckedItem < ActiveRecord::Migration
  def change
    add_column :checked_items, :librarian_id, :integer
  end
end
