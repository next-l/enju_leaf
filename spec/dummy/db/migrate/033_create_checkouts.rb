class CreateCheckouts < ActiveRecord::Migration
  def self.up
    create_table :checkouts do |t|
      t.references :user, index: true
      t.references :item, null: false, index: true
      t.references :checkin, index: true
      t.integer :librarian_id
      t.references :basket, index: true
      t.datetime :due_date
      t.integer :checkout_renewal_count, default: 0, null: false
      t.integer :lock_version, default: 0, null: false
      t.timestamps
    end
    add_index :checkouts, [:item_id, :basket_id], unique: true
    add_index :checkouts, :librarian_id
  end

  def self.down
    drop_table :checkouts
  end
end
