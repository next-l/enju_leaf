class AddColumnsToSeriesStatement < ActiveRecord::Migration
  def change
    add_column :series_statements, :nacsis_series_statementid, :string
    add_column :series_statements, :relationship_family_id, :integer
  end
end
