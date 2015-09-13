class RenameFileNameToFilename < ActiveRecord::Migration
  def change
    rename_column :agent_import_files, :agent_import_file_name, :agent_import_filename
    rename_column :resource_import_files, :resource_import_file_name, :resource_import_filename
    rename_column :manifestations, :attachment_file_name, :attachment_filename
    rename_column :picture_files, :picture_file_name, :picture_filename
  end
end
