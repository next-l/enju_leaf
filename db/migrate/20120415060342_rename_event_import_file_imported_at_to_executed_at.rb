class RenameEventImportFileImportedAtToExecutedAt < ActiveRecord::Migration
  def up
    rename_column :event_import_files, :imported_at, :executed_at
  end

  def down
    rename_column :event_import_files, :executed_at, :imported_at
  end
end
