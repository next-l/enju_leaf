class AddFingerprintToResourceImportFile < ActiveRecord::Migration
  def change
    add_column :resource_import_files, :resource_import_fingerprint, :string
  end
end
