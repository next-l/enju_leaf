class AddErrorMessageToEventImportFile < ActiveRecord::Migration[4.2]
  def change
    add_column :event_import_files, :error_message, :text
  end
end
