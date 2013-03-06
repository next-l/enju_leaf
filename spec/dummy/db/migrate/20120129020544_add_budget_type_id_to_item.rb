class AddBudgetTypeIdToItem < ActiveRecord::Migration
  def change
    add_column :items, :budget_type_id, :integer

  end
end
