class AddForeignKeyToItemsReferencingManifestations < ActiveRecord::Migration[4.2]
  def change
    add_foreign_key :items, :manifestations
  end
end
