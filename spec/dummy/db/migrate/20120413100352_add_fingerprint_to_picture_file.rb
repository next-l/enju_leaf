class AddFingerprintToPictureFile < ActiveRecord::Migration[5.1]
  def change
    add_column :picture_files, :picture_fingerprint, :string
  end
end
