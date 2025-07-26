class AddIndexToOwnsOnItemIdAndAgentId < ActiveRecord::Migration[6.1]
  def change
    remove_index :owns, :item_id
    add_index :owns, [:item_id, :agent_id], unique: true
  end
end
