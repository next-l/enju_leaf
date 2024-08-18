class AddFingerprintToInventoryFile < ActiveRecord::Migration[4.2]
  def up
    add_column :inventory_files, :inventory_fingerprint, :string, if_not_exists: true
  end

  def down
    remove_column :inventory_files, :inventory_fingerprint, :string
  end
end
