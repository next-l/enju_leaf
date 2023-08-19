class CreateOrderLists < ActiveRecord::Migration[6.1]
  def change
    create_table :order_lists do |t|
      t.references :user, foreign_key: true, null: false
      t.references :bookstore, foreign_key: true, null: false
      t.text :title, null: false
      t.text :note
      t.datetime :ordered_at

      t.timestamps
    end
  end
end
