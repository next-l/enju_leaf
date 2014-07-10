class AddUserEncodingToEventImportFile < ActiveRecord::Migration
  def change
    add_column :event_import_files, :user_encoding, :string
  end
end
