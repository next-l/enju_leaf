class AddFingerprintToInventoryFile < ActiveRecord::Migration
  def change
    add_column :inventory_files, :picture_fingerprint, :string
  end
end
