class CreateCheckouts < ActiveRecord::Migration[5.0]
  def change
    create_table :checkouts do |t|
      t.references :user, foreign_key: true
      t.references :item, null: false, foreign_key: true, type: :uuid
      t.references :checkin, foreign_key: true
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
end
