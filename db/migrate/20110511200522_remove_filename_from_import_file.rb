class RemoveFilenameFromImportFile < ActiveRecord::Migration
  def self.up
    remove_column :resource_import_files, :filename
    remove_column :patron_import_files, :filename
  end

  def self.down
    add_column :patron_import_files, :filename, :string
    add_column :resource_import_files, :filename, :string
  end
end
