class CreateSubscriptions < ActiveRecord::Migration[5.1]
  def change
    create_table :subscriptions do |t|
      t.text :title, null: false
      t.text :note
      #t.integer :subscription_list_id, :integer
      t.references :user, foreign_key: true
      t.integer :order_list_id
      t.integer :subscribes_count, default: 0, null: false

      t.timestamps
    end
    add_index :subscriptions, :order_list_id
  end
end
