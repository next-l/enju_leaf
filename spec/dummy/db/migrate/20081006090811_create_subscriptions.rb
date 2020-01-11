class CreateSubscriptions < ActiveRecord::Migration[5.2]
  def change
    create_table :subscriptions do |t|
      t.text :title, null: false
      t.text :note, comment: '備考'
      t.references :user, foreign_key: true
      t.references :order_list, index: true
      t.integer :subscribes_count, default: 0, null: false

      t.timestamps
    end
  end
end
