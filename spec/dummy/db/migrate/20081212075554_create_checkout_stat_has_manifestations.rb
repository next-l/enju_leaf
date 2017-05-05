class CreateCheckoutStatHasManifestations < ActiveRecord::Migration[5.0]
  def change
    create_table :checkout_stat_has_manifestations do |t|
      t.integer :manifestation_checkout_stat_id, null: false
      t.references :manifestation, foreign_key: true, null: false, type: :uuid
      t.integer :checkouts_count

      t.timestamps
    end
    add_index :checkout_stat_has_manifestations, :manifestation_checkout_stat_id, name: 'index_checkout_stat_has_manifestations_on_checkout_stat_id'
  end
end
