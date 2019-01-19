class CreateManifestationReserveStatTransitions < ActiveRecord::Migration[5.2]
  def change
    create_table :manifestation_reserve_stat_transitions do |t|
      t.string :to_state
      t.jsonb :metadata, default: {}
      t.integer :sort_key
      t.references :manifestation_reserve_stat, index: false
      t.timestamps
    end

    add_index :manifestation_reserve_stat_transitions, :manifestation_reserve_stat_id, name: "index_manifestation_reserve_stat_transitions_on_stat_id"
    add_index :manifestation_reserve_stat_transitions, [:sort_key, :manifestation_reserve_stat_id], unique: true, name: "index_manifestation_reserve_stat_transitions_on_transition"
  end
end
