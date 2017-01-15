class CreateManifestationReserveStatTransitions < ActiveRecord::Migration
  def change
    create_table :manifestation_reserve_stat_transitions do |t|
      t.string :to_state, null: false
      t.jsonb :metadata, default: "{}"
      t.integer :sort_key, null: false
      t.integer :manifestation_reserve_stat_id, null: false
      t.timestamps null: false
    end

    add_index :manifestation_reserve_stat_transitions, :manifestation_reserve_stat_id, name: 'index_manifestation_reserve_stat_transitions_on_stat_id'
    add_index :manifestation_reserve_stat_transitions, [:sort_key, :manifestation_reserve_stat_id], unique: true, name: 'index_manifestation_reserve_stat_transitions_on_transition'
  end
end
