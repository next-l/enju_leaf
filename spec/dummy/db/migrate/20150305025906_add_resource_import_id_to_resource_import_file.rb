class AddResourceImportIdToResourceImportFile < ActiveRecord::Migration
  def change
    add_column :resource_import_files, :resource_import_id, :string
    rename_column :resource_import_files, :resource_import_file_size, :resource_import_size
    add_index :resource_import_files, :resource_import_id
  end
end
