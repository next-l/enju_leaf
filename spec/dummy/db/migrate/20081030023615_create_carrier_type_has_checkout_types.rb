class CreateCarrierTypeHasCheckoutTypes < ActiveRecord::Migration[5.1]
  def change
    create_table :carrier_type_has_checkout_types do |t|
      t.references :carrier_type, null: false, foreign_key: true
      t.references :checkout_type, null: false, foreign_key: true
      t.text :note
      t.integer :position

      t.timestamps
    end
  end
end
