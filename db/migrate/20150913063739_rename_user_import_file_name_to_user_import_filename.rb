class RenameUserImportFileNameToUserImportFilename < ActiveRecord::Migration
  def change
    rename_column :user_import_files, :user_import_file_name, :user_import_filename
  end
end
