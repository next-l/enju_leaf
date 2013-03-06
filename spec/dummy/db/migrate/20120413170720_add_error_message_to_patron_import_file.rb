class AddErrorMessageToPatronImportFile < ActiveRecord::Migration
  def change
    add_column :patron_import_files, :error_message, :text
  end
end
