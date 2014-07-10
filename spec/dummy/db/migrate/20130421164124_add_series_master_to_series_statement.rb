class AddSeriesMasterToSeriesStatement < ActiveRecord::Migration
  def change
    add_column :series_statements, :series_master, :boolean
  end
end
