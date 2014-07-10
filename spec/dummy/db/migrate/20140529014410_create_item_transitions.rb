class CreateItemTransitions < ActiveRecord::Migration
  def change
    create_table :item_transitions do |t|
      t.string :to_state
      t.text :metadata, default: "{}"
      t.integer :sort_key
      t.integer :item_id
      t.timestamps
    end

    add_index :item_transitions, :item_id
    add_index :item_transitions, [:sort_key, :item_id], unique: true
  end
end
