class CreateItemTransitions < ActiveRecord::Migration[5.1]
  def change
    create_table :item_transitions do |t|
      t.string :to_state, null: false
      t.jsonb :metadata, default: {}
      t.integer :sort_key, null: false
      t.uuid :item_id, null: false
      t.boolean :most_recent, null: false
      t.timestamps null: false
    end

    add_index :item_transitions, :item_id
    add_index :item_transitions, [:sort_key, :item_id], unique: true
  end
end
