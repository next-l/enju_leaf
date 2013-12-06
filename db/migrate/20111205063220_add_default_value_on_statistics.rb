class AddDefaultValueOnStatistics < ActiveRecord::Migration
  def self.up
    change_column_default :statistics, :option, 0
  end

  def self.down
  end
end
