class AddFingerprintToResourceImportFile < ActiveRecord::Migration[4.2]
  def change
    add_column :resource_import_files, :resource_import_fingerprint, :string
  end
end
