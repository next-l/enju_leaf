class CreateOrderLists < ActiveRecord::Migration
  def self.up
    create_table :order_lists do |t|
      t.integer :user_id, :null => false
      t.integer :bookstore_id, :null => false
      t.text :title, :null => false
      t.text :note
      t.datetime :ordered_at
      t.datetime :deleted_at
      t.string :state

      t.timestamps
    end
    add_index :order_lists, :user_id
    add_index :order_lists, :bookstore_id
  end

  def self.down
    drop_table :order_lists
  end
end
