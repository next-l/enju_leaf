class CreateCheckouts < ActiveRecord::Migration
  def self.up
    create_table :checkouts do |t|
      t.integer :user_id
      t.integer :item_id, :null => false
      t.integer :checkin_id
      t.integer :librarian_id
      t.integer :basket_id
      t.datetime :due_date
      t.integer :checkout_renewal_count, :default => 0, :null => false
      t.integer :lock_version, :default => 0, :null => false
      t.timestamps
    end
    add_index :checkouts, :user_id
    add_index :checkouts, :item_id
    add_index :checkouts, :basket_id
    add_index :checkouts, [:item_id, :basket_id], :unique => true
    add_index :checkouts, :librarian_id
    add_index :checkouts, :checkin_id
  end

  def self.down
    drop_table :checkouts
  end
end
