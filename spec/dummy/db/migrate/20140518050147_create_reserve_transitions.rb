class CreateReserveTransitions < ActiveRecord::Migration
  def change
    create_table :reserve_transitions do |t|
      t.string :to_state, null: false
      t.jsonb :metadata, default: '{}'
      t.integer :sort_key, null: false
      t.integer :reserve_id, null: false
      t.timestamps null: false
    end

    add_index :reserve_transitions, :reserve_id
    add_index :reserve_transitions, [:sort_key, :reserve_id], unique: true
  end
end
