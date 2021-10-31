class RenameEventImportFileImportedAtToExecutedAt < ActiveRecord::Migration[4.2]
  def up
    rename_column :event_import_files, :imported_at, :executed_at
  end

  def down
    rename_column :event_import_files, :executed_at, :impored_at
  end
end
