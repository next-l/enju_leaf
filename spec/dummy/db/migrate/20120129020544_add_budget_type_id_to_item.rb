class AddBudgetTypeIdToItem < ActiveRecord::Migration[4.2]
  def change
    add_column :items, :budget_type_id, :integer

  end
end
