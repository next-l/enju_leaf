class RemoveNcidFromManifestations < ActiveRecord::Migration[4.2]
  def up
    remove_column :manifestations, :ncid
  end

  def down
    add_column :manifestations, :ncid
    add_index :manifestations, :ncid
  end
end
