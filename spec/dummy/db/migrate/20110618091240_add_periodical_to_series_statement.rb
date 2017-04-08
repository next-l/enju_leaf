class AddPeriodicalToSeriesStatement < ActiveRecord::Migration[5.0]
  def self.up
    add_column :series_statements, :periodical, :boolean
  end

  def self.down
    remove_column :series_statements, :periodical
  end
end
