class CreateOrders < ActiveRecord::Migration[6.1]
  def change
    create_table :orders do |t|
      t.references :order_list, foreign_key: true, null: false
      t.references :purchase_request, foreign_key: true, null: false
      t.integer :position
      t.string :state

      t.timestamps
    end
  end
end
