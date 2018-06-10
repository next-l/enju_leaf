class AddErrorMessageToResourceImportResult < ActiveRecord::Migration[4.2]
  def change
    add_column :resource_import_results, :error_message, :text
  end
end
