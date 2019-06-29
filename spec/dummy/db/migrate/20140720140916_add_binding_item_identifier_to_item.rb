class AddBindingItemIdentifierToItem < ActiveRecord::Migration[4.2]
  def change
    add_column :items, :binding_item_identifier, :string
    add_column :items, :binding_call_number, :string
    add_column :items, :binded_at, :datetime
    add_index :items, :binding_item_identifier
  end
end
