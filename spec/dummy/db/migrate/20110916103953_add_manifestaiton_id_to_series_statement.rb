class AddManifestaitonIdToSeriesStatement < ActiveRecord::Migration[5.2]
  def change
    add_reference :series_statements, :manifestation, foreign_key: true
  end
end
