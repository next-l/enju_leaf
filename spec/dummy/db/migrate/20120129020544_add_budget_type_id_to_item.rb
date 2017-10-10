class AddBudgetTypeIdToItem < ActiveRecord::Migration[5.1]
  def change
    add_column :items, :budget_type_id, :integer

  end
end
