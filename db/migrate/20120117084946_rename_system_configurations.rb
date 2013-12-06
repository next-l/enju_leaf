class RenameSystemConfigurations < ActiveRecord::Migration
  def self.up
    rename_table :system_configrations, :system_configurations
  end

  def self.down
    rename_table :system_configurations, :system_configrations
  end
end
