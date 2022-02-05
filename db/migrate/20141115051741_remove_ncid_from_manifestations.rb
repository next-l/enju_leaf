class RemoveNcidFromManifestations < ActiveRecord::Migration[4.2]
  def change
    remove_column :manifestations, :ncid
  end
end
