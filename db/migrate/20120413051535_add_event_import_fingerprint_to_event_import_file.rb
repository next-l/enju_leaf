class AddEventImportFingerprintToEventImportFile < ActiveRecord::Migration[4.2]
  def change
    add_column :event_import_files, :event_import_fingerprint, :string
  end
end
