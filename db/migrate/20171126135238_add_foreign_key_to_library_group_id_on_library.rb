class AddForeignKeyToLibraryGroupIdOnLibrary < ActiveRecord::Migration[4.2]
  def up
    add_foreign_key :libraries, :library_groups, null: false
  end

  def down
    remove_foreign_key :libraries, :library_groups
  end
end
