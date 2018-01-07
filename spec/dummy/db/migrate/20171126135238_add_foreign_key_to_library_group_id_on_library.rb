class AddForeignKeyToLibraryGroupIdOnLibrary < ActiveRecord::Migration
  def change
    add_foreign_key :libraries, :library_groups, null: false
  end
end
