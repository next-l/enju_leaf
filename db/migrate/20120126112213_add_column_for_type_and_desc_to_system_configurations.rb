class AddColumnForTypeAndDescToSystemConfigurations < ActiveRecord::Migration
  def self.up
    add_column :system_configurations, :typename, :string
    add_column :system_configurations, :description, :string
  end

  def self.down
    remove_column :system_configurations, :type
    remove_column :system_configurations, :description
  end
end
