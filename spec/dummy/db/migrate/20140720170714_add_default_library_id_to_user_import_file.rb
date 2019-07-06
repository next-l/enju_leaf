class AddDefaultLibraryIdToUserImportFile < ActiveRecord::Migration[4.2]
  def change
    add_reference :user_import_files, :default_library
  end
end
