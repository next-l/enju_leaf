class AddFingerprintToInventoryFile < ActiveRecord::Migration[4.2]
  def change
    add_column :inventory_files, :inventory_fingerprint, :string
  end
end
