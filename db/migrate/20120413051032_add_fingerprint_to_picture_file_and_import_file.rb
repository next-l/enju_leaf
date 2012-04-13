class AddFingerprintToPictureFileAndImportFile < ActiveRecord::Migration
  def change
    add_column :picture_files, :picture_fingerprint, :string
    add_column :resource_import_files, :resource_import_fingerprint, :string
    add_column :patron_import_files, :patron_import_fingerprint, :string
    add_column :manifestations, :attachment_fingerprint, :string
  end
end
