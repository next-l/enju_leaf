class CreatePurchaseRequests < ActiveRecord::Migration
  def self.up
    create_table :purchase_requests do |t|
      t.integer :user_id, :null => false
      t.text :title, :null => false
      t.text :author
      t.text :publisher
      t.string :isbn
      t.datetime :date_of_publication
      t.integer :price
      t.string :url
      t.text :note
      t.datetime :accepted_at
      t.datetime :denied_at
      t.datetime :created_at
      t.datetime :updated_at
      t.datetime :deleted_at
      t.string :state

      t.timestamps
    end
    add_index :purchase_requests, :user_id
    add_index :purchase_requests, :state
  end

  def self.down
    drop_table :purchase_requests
  end
end
