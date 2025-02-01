class CreateOrders < ActiveRecord::Migration[6.1]
  def up
    create_table :orders, if_not_exists: true do |t|
      t.references :order_list, foreign_key: true, null: false
      t.references :purchase_request, foreign_key: true, null: false
      t.integer :position

      t.timestamps
    end
  end

  def down
    drop_table :orders
  end
end
