class CreateOrderLists < ActiveRecord::Migration[6.1]
  def up
    create_table :order_lists, if_not_exists: true do |t|
      t.references :user, foreign_key: true, null: false
      t.references :bookstore, foreign_key: true, null: false
      t.text :title, null: false
      t.text :note
      t.datetime :ordered_at

      t.timestamps
    end
  end

  def down
    drop_table :order_lists
  end
end
