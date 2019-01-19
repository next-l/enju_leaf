class AddErrorMessageToResourceImportFile < ActiveRecord::Migration[5.2]
  def change
    add_column :resource_import_files, :error_message, :text
  end
end
