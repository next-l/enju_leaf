class AddFingerprintToEventImportFile < ActiveRecord::Migration
  def change
    add_column :event_import_files, :picture_fingerprint, :string
  end
end
