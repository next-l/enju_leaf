class CreateAgentMerges < ActiveRecord::Migration[4.2]
  def up
    create_table :agent_merges do |t|
      t.integer :agent_id, :agent_merge_list_id, null: false

      t.timestamps
    end
    add_index :agent_merges, :agent_id
    add_index :agent_merges, :agent_merge_list_id
  end

  def down
    drop_table :agent_merges
  end
end
