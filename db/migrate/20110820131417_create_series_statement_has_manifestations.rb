class CreateSeriesStatementHasManifestations < ActiveRecord::Migration
  def self.up
    create_table :series_statement_has_manifestations do |t|
      t.integer :series_statement_id
      t.integer :manifestation_id
      t.integer :position

      t.timestamps
    end
  end

  def self.down
    drop_table :series_statement_has_manifestations
  end
end
