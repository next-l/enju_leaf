class AddManifestaitonIdToSeriesStatement < ActiveRecord::Migration[5.1]
  def change
    add_reference :series_statements, :manifestation, type: :uuid, foreign_key: true
  end
end
