class AddUserExportIdToUserExportFile < ActiveRecord::Migration
  def change
    add_column :user_export_files, :user_export_id, :string
    add_column :user_export_files, :user_export_size, :integer
    rename_column :user_export_files, :user_import_file_name, :user_export_filename
    add_index :user_export_files, :user_export_id
  end
end
