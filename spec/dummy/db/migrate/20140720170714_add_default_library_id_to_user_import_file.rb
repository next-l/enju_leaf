class AddDefaultLibraryIdToUserImportFile < ActiveRecord::Migration
  def change
    add_column :user_import_files, :default_library_id, :integer
  end
end
