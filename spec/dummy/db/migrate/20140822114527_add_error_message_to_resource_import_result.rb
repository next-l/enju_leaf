class AddErrorMessageToResourceImportResult < ActiveRecord::Migration
  def change
    add_column :resource_import_results, :error_message, :text
  end
end
