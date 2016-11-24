class CreateCheckoutStatHasManifestations < ActiveRecord::Migration
  def self.up
    create_table :checkout_stat_has_manifestations do |t|
      t.integer :manifestation_checkout_stat_id, null: false
      t.integer :manifestation_id, null: false
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
