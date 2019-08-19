class AddManifestaitonIdToSeriesStatement < ActiveRecord::Migration[5.2]
  def self.up
    add_column :series_statements, :manifestation_id, :integer
    add_index :series_statements, :manifestation_id
  end

  def self.down
    remove_column :series_statements, :manifestation_id
  end
end
