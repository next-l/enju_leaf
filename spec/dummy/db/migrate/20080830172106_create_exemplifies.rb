class CreateExemplifies < ActiveRecord::Migration[4.2]
  def change
    create_table :exemplifies do |t|
      t.integer :manifestation_id, null: false
      t.integer :item_id, null: false
      t.integer :position

      t.timestamps
    end
    add_index :exemplifies, :manifestation_id
    add_index :exemplifies, :item_id, unique: true
  end
end
