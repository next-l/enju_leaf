class AddErrorMessageToResourceImportFile < ActiveRecord::Migration
  def change
    add_column :resource_import_files, :error_message, :text
  end
end
