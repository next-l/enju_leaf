class CreateCheckouts < ActiveRecord::Migration[5.2]
  def change
    create_table :checkouts do |t|
      t.references :user, foreign_key: true
      t.references :item, foreign_key: true, null: false
      t.references :checkin, foreign_key: true
      t.references :librarian, foreign_key: {to_table: :users}
      t.references :basket, index: true
      t.datetime :due_date
      t.integer :checkout_renewal_count, default: 0, null: false
      t.integer :lock_version, default: 0, null: false
      t.timestamps
    end
    add_index :checkouts, [:item_id, :basket_id], unique: true
  end
end
