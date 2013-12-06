class AddColumnOnStatistics < ActiveRecord::Migration
  def self.up
    add_column :statistics, :hour, :integer
    add_column :statistics, :day, :integer
  end

  def self.down
    remove_column :statistics, :hour
    remove_column :statistics, :day
  end
end
