class AddBudgetTypeIdOnBudgets < ActiveRecord::Migration
  def self.up
    add_column :budgets, :budget_type_id, :integer
  end

  def self.down
    remove_column :budgets, :budget_type_id
  end
end
