class CreateManifestationHasCarrierTypes < ActiveRecord::Migration
  def change
    create_table :manifestation_has_carrier_types do |t|
      t.integer :manifestation_id
      t.integer :carrier_type_id

      t.timestamps
    end
    add_index :manifestation_has_carrier_types, :manifestation_id
    add_index :manifestation_has_carrier_types, :carrier_type_id
  end

end
