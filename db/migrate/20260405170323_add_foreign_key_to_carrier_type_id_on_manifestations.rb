class AddForeignKeyToCarrierTypeIdOnManifestations < ActiveRecord::Migration[7.2]
  def change
    add_foreign_key :manifestations, :carrier_types
    add_foreign_key :manifestations, :content_types
    add_foreign_key :manifestations, :frequencies
    add_foreign_key :manifestations, :languages
    add_foreign_key :manifestations, :nii_types
  end
end
