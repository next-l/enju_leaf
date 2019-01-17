class CreateSubscriptions < ActiveRecord::Migration[5.2]
  def change
    create_table :subscriptions do |t|
      t.text :title, null: false
      t.text :note
      t.references :user, index: true
      t.references :order_list, index: true
      t.integer :subscribes_count, default: 0, null: false

      t.timestamps
    end
  end
end
