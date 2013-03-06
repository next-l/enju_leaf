class RenameResourceImportFileImportedAtToExecutedAt < ActiveRecord::Migration
  def up
    rename_column :resource_import_files, :imported_at, :executed_at
  end

  def down
    rename_column :resource_import_files, :executed_at, :imported_at
  end
end
