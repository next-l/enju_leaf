class AddLibrarianIdToCheckedItem < ActiveRecord::Migration[5.2]
  def change
    add_reference :checked_items, :user, index: true, foreign_key: true, column_name: :librarian_id
  end
end
