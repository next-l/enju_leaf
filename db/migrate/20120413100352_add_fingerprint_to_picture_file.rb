class AddFingerprintToPictureFile < ActiveRecord::Migration[4.2]
  def change
    add_column :picture_files, :picture_fingerprint, :string
  end
end
