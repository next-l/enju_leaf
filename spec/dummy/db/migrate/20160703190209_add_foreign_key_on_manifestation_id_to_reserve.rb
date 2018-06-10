class AddForeignKeyOnManifestationIdToReserve < ActiveRecord::Migration[4.2]
  def change
    add_foreign_key :reserves, :manifestations
  end
end
