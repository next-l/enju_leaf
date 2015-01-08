class CreateManifestationCheckoutStatTransitions < ActiveRecord::Migration
  def change
    create_table :manifestation_checkout_stat_transitions do |t|
      t.string :to_state
      if ActiveRecord::Base.configurations[Rails.env]["adapter"].try(:match, /mysql/)
        t.text :metadata
      else
        t.text :metadata, default: "{}"
      end
      t.integer :sort_key
      t.integer :manifestation_checkout_stat_id
      t.timestamps
    end

    add_index :manifestation_checkout_stat_transitions, :manifestation_checkout_stat_id, name: "index_manifestation_checkout_stat_transitions_on_stat_id"
    add_index :manifestation_checkout_stat_transitions, [:sort_key, :manifestation_checkout_stat_id], unique: true, name: "index_manifestation_checkout_stat_transitions_on_transition"
  end
end
