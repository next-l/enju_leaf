class AddBudgetTypeIdToItem < ActiveRecord::Migration[5.1]
  def change
    add_reference :items, :budget_type, foreign_key: true
  end
end
