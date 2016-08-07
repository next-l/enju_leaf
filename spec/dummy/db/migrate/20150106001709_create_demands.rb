class CreateDemands < ActiveRecord::Migration
  def change
    create_table :demands do |t|
      t.integer :user_id
      t.integer :item_id
      t.integer :message_id

      t.timestamps null: false
    end
    add_index :demands, :user_id
    add_index :demands, :item_id
    add_index :demands, :message_id
  end
end
