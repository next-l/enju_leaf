class AddUniqueIndexToCarrierTypeHasCheckoutTypesOnCarrierTypeIdAndCheckoutTypeId < ActiveRecord::Migration[6.1]
  def change
    remove_index :carrier_type_has_checkout_types, :carrier_type_id
    add_index :carrier_type_has_checkout_types, [:carrier_type_id, :checkout_type_id], unique: true, name: 'index_carrier_type_has_checkout_types_on_carrier_type_id'

    remove_index :user_group_has_checkout_types, :user_group_id
    add_index :user_group_has_checkout_types, [:user_group_id, :checkout_type_id], unique: true, name: 'index_user_group_has_checkout_types_on_user_group_id'
  end
end
