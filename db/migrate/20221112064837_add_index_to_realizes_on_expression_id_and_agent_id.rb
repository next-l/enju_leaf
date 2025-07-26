class AddIndexToRealizesOnExpressionIdAndAgentId < ActiveRecord::Migration[6.1]
  def change
    remove_index :realizes, :expression_id
    add_index :realizes, [:expression_id, :agent_id], unique: true
  end
end
