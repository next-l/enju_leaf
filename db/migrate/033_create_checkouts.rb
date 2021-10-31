class CreateCheckouts < ActiveRecord::Migration[4.2]
  def self.up
    create_table :checkouts do |t|
      t.references :user, index: true, foreign_key: true
      t.references :item, index: true, foreign_key: true, null: false
      t.references :checkin, index: true, foreign_key: true
      t.references :librarian, index: true
      t.references :basket, index: true
      t.datetime :due_date
      t.integer :checkout_renewal_count, default: 0, null: false
      t.integer :lock_version, default: 0, null: false
      t.timestamps
    end
    add_index :checkouts, [:item_id, :basket_id], unique: true
  end

  def self.down
    drop_table :checkouts
  end
end
