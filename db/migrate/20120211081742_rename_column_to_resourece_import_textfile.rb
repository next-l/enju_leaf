class RenameColumnToResoureceImportTextfile < ActiveRecord::Migration
  def self.up
    rename_column :resource_import_textfiles, :resource_import_file_name, :resource_import_text_file_name
    rename_column :resource_import_textfiles, :resource_import_content_type, :resource_import_text_content_type
    rename_column :resource_import_textfiles, :resource_import_file_size, :resource_import_text_file_size
    rename_column :resource_import_textfiles, :resource_import_updated_at, :resource_import_text_updated_at
  end

  def self.down
    rename_column :resource_import_textfiles, :resource_import_text_file_name, :resource_import_file_name
    rename_column :resource_import_textfiles, :resource_import_text_content_type, :resource_import_content_type
    rename_column :resource_import_textfiles, :resource_import_text_file_sizei, :resource_import_file_size
    rename_column :resource_import_textfiles, :resource_import_text_updated_at, :resource_import_updated_at
  end
end
