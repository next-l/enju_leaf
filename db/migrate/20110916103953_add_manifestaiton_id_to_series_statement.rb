class AddManifestaitonIdToSeriesStatement < ActiveRecord::Migration[4.2]
  def up
    add_column :series_statements, :manifestation_id, :integer
    add_index :series_statements, :manifestation_id
  end

  def down
    remove_column :series_statements, :manifestation_id
  end
end
