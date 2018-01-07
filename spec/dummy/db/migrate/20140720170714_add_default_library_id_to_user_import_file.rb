class AddDefaultLibraryIdToUserImportFile < ActiveRecord::Migration
  def change
    add_reference :user_import_files, :default_library
  end
end
