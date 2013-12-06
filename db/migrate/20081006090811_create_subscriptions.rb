class CreateSubscriptions < ActiveRecord::Migration
  def self.up
    create_table :subscriptions do |t|
      t.text :title, :null => false
      t.text :note
      #t.integer :subscription_list_id, :integer
      t.integer :user_id
      t.integer :order_list_id
      t.datetime :deleted_at
      t.integer :subscribes_count, :default => 0, :null => false

      t.timestamps
    end
    add_index :subscriptions, :user_id
    add_index :subscriptions, :order_list_id
  end

  def self.down
    drop_table :subscriptions
  end
end
