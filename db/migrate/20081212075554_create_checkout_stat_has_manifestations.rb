class CreateCheckoutStatHasManifestations < ActiveRecord::Migration[4.2]
  def self.up
    create_table :checkout_stat_has_manifestations do |t|
      t.references :manifestation_checkout_stat, index: false, null: false
      t.references :manifestation, index: false, foreign_key: true, null: false
      t.integer :checkouts_count

      t.timestamps
    end
    add_index :checkout_stat_has_manifestations, :manifestation_checkout_stat_id, name: 'index_checkout_stat_has_manifestations_on_checkout_stat_id'
    add_index :checkout_stat_has_manifestations, :manifestation_id, name: 'index_checkout_stat_has_manifestations_on_manifestation_id'
  end

  def self.down
    drop_table :checkout_stat_has_manifestations
  end
end
