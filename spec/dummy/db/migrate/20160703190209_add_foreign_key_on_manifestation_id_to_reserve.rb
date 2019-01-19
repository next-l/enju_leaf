class AddForeignKeyOnManifestationIdToReserve < ActiveRecord::Migration[5.2]
  def change
    add_foreign_key :reserves, :manifestations
  end
end
