class AddErrorMessageToUserImportResult < ActiveRecord::Migration[5.2]
  def change
    add_column :user_import_results, :error_message, :text
  end
end
