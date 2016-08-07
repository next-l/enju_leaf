class AddForeignKeyOnManifestationIdToReserve < ActiveRecord::Migration
  def change
    add_foreign_key :reserves, :manifestations
  end
end
