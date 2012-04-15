class AddFingerprintToPatronImportFile < ActiveRecord::Migration
  def change
    add_column :patron_import_files, :patron_import_fingerprint, :string
  end
end
