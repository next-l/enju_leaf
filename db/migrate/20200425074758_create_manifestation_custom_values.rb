class CreateManifestationCustomValues < ActiveRecord::Migration[5.2]
  def change
    create_table :manifestation_custom_values do |t|
      t.references :manifestation_custom_property, null: false, foreign_key: true, index: {name: 'index_manifestation_custom_values_on_custom_property_id'}
      t.references :manifestation, null: false, foreign_key: true
      t.text :value

      t.timestamps
    end
    add_index :manifestation_custom_values, [:manifestation_custom_property_id, :manifestation_id], unique: true, name: 'index_manifestation_custom_values_on_property_manifestation'
  end
end
