class AddLibrarianIdToCheckedItem < ActiveRecord::Migration[5.1]
  def change
    add_column :checked_items, :librarian_id, :integer
  end
end
