class AddDefaultLibraryIdToUserImportFile < ActiveRecord::Migration[5.2]
  def change
    add_reference :user_import_files, :default_library, type: :uuid
  end
end
