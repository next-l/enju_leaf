class CreateCarrierTypeHasCheckoutTypes < ActiveRecord::Migration
  def change
    create_table :carrier_type_has_checkout_types do |t|
      t.integer :carrier_type_id, :null => false
      t.integer :checkout_type_id, :null => false
      t.text :note
      t.integer :position

      t.timestamps
    end
    add_index :carrier_type_has_checkout_types, :carrier_type_id, :name => 'index_carrier_type_has_checkout_types_on_m_form_id'
    add_index :carrier_type_has_checkout_types, :checkout_type_id
  end
end
