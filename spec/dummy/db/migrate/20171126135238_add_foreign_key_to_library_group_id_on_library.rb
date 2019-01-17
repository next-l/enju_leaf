class AddForeignKeyToLibraryGroupIdOnLibrary < ActiveRecord::Migration[5.2]
  def change
    add_foreign_key :libraries, :library_groups, null: false
  end
end
