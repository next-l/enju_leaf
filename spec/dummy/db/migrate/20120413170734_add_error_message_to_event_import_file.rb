class AddErrorMessageToEventImportFile < ActiveRecord::Migration
  def change
    add_column :event_import_files, :error_message, :text
  end
end
