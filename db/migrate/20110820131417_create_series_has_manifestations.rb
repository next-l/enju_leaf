class CreateSeriesHasManifestations < ActiveRecord::Migration
  def self.up
    create_table :series_has_manifestations do |t|
      t.integer :series_statement_id
      t.integer :manifestation_id
      t.integer :position

      t.timestamps
    end
    add_index :series_has_manifestations, :series_statement_id
    add_index :series_has_manifestations, :manifestation_id
  end

  def self.down
    drop_table :series_has_manifestations
  end
end
