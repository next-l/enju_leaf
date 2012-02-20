class AddColumnForTimestampsToBudgets < ActiveRecord::Migration
  def self.up
    add_column :budgets, :created_at, :timestamp
    add_column :budgets, :updated_at, :timestamp
  end

  def self.down
    remove_column :budgets, :updated_at
    remove_column :budgets, :created_at
  end
end
