class AddFingerprintToPictureFile < ActiveRecord::Migration
  def change
    add_column :picture_files, :picture_fingerprint, :string
  end
end
