class AddFingerprintToInventoryFile < ActiveRecord::Migration
  def change
    add_column :inventory_files, :inventory_fingerprint, :string
  end
end
