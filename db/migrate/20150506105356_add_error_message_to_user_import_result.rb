class AddErrorMessageToUserImportResult < ActiveRecord::Migration
  def change
    add_column :user_import_results, :error_message, :text
  end
end
