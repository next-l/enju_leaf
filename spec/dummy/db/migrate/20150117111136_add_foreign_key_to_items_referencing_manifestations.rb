class AddForeignKeyToItemsReferencingManifestations < ActiveRecord::Migration[5.2]
  def change
    add_foreign_key :items, :manifestations
  end
end
