class AddSeriesMasterToSeriesStatement < ActiveRecord::Migration[5.1]
  def change
    add_column :series_statements, :series_master, :boolean, default: false, null: false
  end
end
