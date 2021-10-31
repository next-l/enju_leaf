class CreateItemCustomValues < ActiveRecord::Migration[5.2]
  def change
    create_table :item_custom_values do |t|
      t.references :item_custom_property, null: false, foreign_key: true, index: {name: 'index_item_custom_values_on_custom_property_id'}
      t.references :item, null: false, foreign_key: true
      t.text :value

      t.timestamps
    end
    add_index :item_custom_values, [:item_custom_property_id, :item_id], unique: true, name: 'index_item_custom_values_on_custom_item_property_and_item_id'
  end
end
