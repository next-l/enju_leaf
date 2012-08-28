# This migration comes from enju_event_engine (originally 20120415060342)
class RenameEventImportFileImportedAtToExecutedAt < ActiveRecord::Migration
  def up
    rename_column :event_import_files, :imported_at, :executed_at
  end

  def down
    rename_column :event_import_files, :executed_at, :impored_at
  end
end
