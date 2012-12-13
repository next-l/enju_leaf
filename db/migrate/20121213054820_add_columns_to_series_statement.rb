class AddColumnsToSeriesStatement < ActiveRecord::Migration
  def change
    add_column :series_statements, :manifestation_type_id, :integer
    add_column :series_statements, :frequency_id, :integer
  end
end
