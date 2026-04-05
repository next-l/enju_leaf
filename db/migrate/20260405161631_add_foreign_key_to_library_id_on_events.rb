class AddForeignKeyToLibraryIdOnEvents < ActiveRecord::Migration[7.2]
  def change
    add_foreign_key :events, :libraries
    add_foreign_key :profiles, :libraries
    add_foreign_key :shelves, :libraries
    change_column_null :profiles, :library_id, false
  end
end
