class AddConstraintsToMostRecentForManifestationCheckoutStatTransitions < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def up
    add_index :manifestation_checkout_stat_transitions, [:manifestation_checkout_stat_id, :most_recent], unique: true, where: "most_recent", name: "index_manifestation_checkout_stat_transitions_parent_most_rece" # , algorithm: :concurrently
    change_column_null :manifestation_checkout_stat_transitions, :most_recent, false
  end

  def down
    remove_index :manifestation_checkout_stat_transitions, name: "index_manifestation_checkout_stat_transitions_parent_most_rece"
    change_column_null :manifestation_checkout_stat_transitions, :most_recent, true
  end
end
