class AddIssnToSeriesStatement < ActiveRecord::Migration
  def self.up
    add_column :series_statements, :issn, :string
  end

  def self.down
    remove_column :series_statements, :issn
  end
end
