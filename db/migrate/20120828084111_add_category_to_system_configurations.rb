class AddCategoryToSystemConfigurations < ActiveRecord::Migration
  def change
    add_column :system_configurations, :category, :string
  end
end
