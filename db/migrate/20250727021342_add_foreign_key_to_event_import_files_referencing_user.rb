class AddForeignKeyToEventImportFilesReferencingUser < ActiveRecord::Migration[7.2]
  def change
    add_foreign_key :event_import_files, :users
    add_foreign_key :accepts, :users, column: :librarian_id
    add_foreign_key :checked_items, :users, column: :librarian_id
    add_foreign_key :checkins, :users, column: :librarian_id
    add_foreign_key :checkouts, :users, column: :librarian_id
    add_foreign_key :withdraws, :users, column: :librarian_id
  end
end
