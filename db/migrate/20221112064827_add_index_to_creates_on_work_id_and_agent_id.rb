class AddIndexToCreatesOnWorkIdAndAgentId < ActiveRecord::Migration[6.1]
  def change
    remove_index :creates, :work_id
    add_index :creates, [:work_id, :agent_id], unique: true
  end
end
