class CreateOrderListTransitions < ActiveRecord::Migration[6.1]
  def change
    create_table :order_list_transitions do |t|
      t.string :to_state
      t.text :metadata, default: "{}"
      t.integer :sort_key
      t.integer :order_list_id
      t.timestamps
    end

    add_index :order_list_transitions, :order_list_id
    add_index :order_list_transitions, [:sort_key, :order_list_id], unique: true
  end
end
