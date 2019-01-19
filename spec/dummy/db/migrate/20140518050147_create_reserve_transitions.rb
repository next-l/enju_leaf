class CreateReserveTransitions < ActiveRecord::Migration[5.2]
  def change
    create_table :reserve_transitions do |t|
      t.string :to_state
      t.jsonb :metadata, default: {}
      t.integer :sort_key
      t.references :reserve
      t.timestamps
    end

    add_index :reserve_transitions, [:sort_key, :reserve_id], unique: true
  end
end
