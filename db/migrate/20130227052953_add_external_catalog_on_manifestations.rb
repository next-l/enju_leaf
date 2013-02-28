class AddExternalCatalogOnManifestations < ActiveRecord::Migration
  def up
    add_column :manifestations, :external_catalog, :integer, :default => 0, :null => false
  end

  def down
    remove_column :manifestations, :external_catalog
  end
end
