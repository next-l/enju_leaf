class CreateCarrierTypeHasCheckoutTypes < ActiveRecord::Migration[4.2]
  def self.up
    create_table :carrier_type_has_checkout_types do |t|
      t.references :carrier_type, index: false, foreign_key: true, null: false
      t.references :checkout_type, index: true, foreign_key: true, null: false
      t.text :note
      t.integer :position

      t.timestamps
    end
    add_index :carrier_type_has_checkout_types, :carrier_type_id, name: 'index_carrier_type_has_checkout_types_on_m_form_id'
  end

  def self.down
    drop_table :carrier_type_has_checkout_types
  end
end
