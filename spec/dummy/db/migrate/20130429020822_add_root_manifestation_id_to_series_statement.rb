class AddRootManifestationIdToSeriesStatement < ActiveRecord::Migration[5.2]
  def change
    add_reference :series_statements, :root_manifestation, foreign_ley: {to_table: :manifestations}
  end
end
