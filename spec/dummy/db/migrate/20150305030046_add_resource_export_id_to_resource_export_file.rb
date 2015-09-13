class AddResourceExportIdToResourceExportFile < ActiveRecord::Migration
  def change
    add_column :resource_export_files, :resource_export_id, :string
    add_column :resource_export_files, :resource_export_size, :integer
    add_column :resource_export_files, :resource_export_filename, :string
    add_index :resource_export_files, :resource_export_id
  end
end
