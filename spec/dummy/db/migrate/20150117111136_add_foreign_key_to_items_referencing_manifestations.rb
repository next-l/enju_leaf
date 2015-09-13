class AddForeignKeyToItemsReferencingManifestations < ActiveRecord::Migration
  def change
    add_foreign_key :items, :manifestations
  end
end
