class CreateManifestationCheckoutStatTransitions < ActiveRecord::Migration[5.2]
  def change
    create_table :manifestation_checkout_stat_transitions do |t|
      t.string :to_state
      t.jsonb :metadata, default: {}
      t.integer :sort_key
      t.references :manifestation_checkout_stat, index: false
      t.timestamps
    end

    add_index :manifestation_checkout_stat_transitions, :manifestation_checkout_stat_id, name: "index_manifestation_checkout_stat_transitions_on_stat_id"
    add_index :manifestation_checkout_stat_transitions, [:sort_key, :manifestation_checkout_stat_id], unique: true, name: "index_manifestation_checkout_stat_transitions_on_transition"
  end
end
