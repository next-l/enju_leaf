class AddRootManifestationIdToSeriesStatement < ActiveRecord::Migration[5.1]
  def change
    add_column :series_statements, :root_manifestation_id, :uuid
    add_index :series_statements, :root_manifestation_id
  end
end
