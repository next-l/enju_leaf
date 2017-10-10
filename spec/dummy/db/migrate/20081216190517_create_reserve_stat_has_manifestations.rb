class CreateReserveStatHasManifestations < ActiveRecord::Migration[5.1]
  def change
    create_table :reserve_stat_has_manifestations do |t|
      t.integer :manifestation_reserve_stat_id, null: false
      t.references :manifestation, foreign_key: true, null: false, type: :uuid
      t.integer :reserves_count

      t.timestamps
    end
    add_index :reserve_stat_has_manifestations, :manifestation_reserve_stat_id, name: 'index_reserve_stat_has_manifestations_on_m_reserve_stat_id'
  end
end
