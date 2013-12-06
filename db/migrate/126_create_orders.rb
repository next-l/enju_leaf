class CreateOrders < ActiveRecord::Migration
  def self.up
    create_table :orders do |t|
      t.integer :order_list_id, :null => false
      t.integer :purchase_request_id, :null => false
      t.integer :position
      t.string :state

      t.timestamps
    end
    add_index :orders, :order_list_id
    add_index :orders, :purchase_request_id
  end

  def self.down
    drop_table :orders
  end
end
