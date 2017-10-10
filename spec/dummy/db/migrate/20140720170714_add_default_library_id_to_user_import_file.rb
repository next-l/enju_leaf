class AddDefaultLibraryIdToUserImportFile < ActiveRecord::Migration[5.1]
  def change
    add_column :user_import_files, :default_library_id, :integer
  end
end
