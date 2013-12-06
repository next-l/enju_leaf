class CreateReserveStatHasManifestations < ActiveRecord::Migration
  def self.up
    create_table :reserve_stat_has_manifestations do |t|
      t.integer :manifestation_reserve_stat_id, :null => false
      t.integer :manifestation_id, :null => false
      t.integer :reserves_count

      t.timestamps
    end
    add_index :reserve_stat_has_manifestations, :manifestation_reserve_stat_id, :name => 'index_reserve_stat_has_manifestations_on_m_reserve_stat_id'
    add_index :reserve_stat_has_manifestations, :manifestation_id
  end

  def self.down
    drop_table :reserve_stat_has_manifestations
  end
end
