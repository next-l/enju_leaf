class AddPeriodicalToSeriesStatement < ActiveRecord::Migration
  def self.up
    add_column :series_statements, :periodical, :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :series_statements, :periodical
  end
end
