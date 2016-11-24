class CreateCarrierTypeHasCheckoutTypes < ActiveRecord::Migration
  def self.up
    create_table :carrier_type_has_checkout_types do |t|
      t.references :carrier_type, null: false, index: true
      t.references :checkout_type, null: false, index: true
      t.text :note
      t.integer :position

      t.timestamps
    end
  end

  def self.down
    drop_table :carrier_type_has_checkout_types
  end
end
