class CreateAgentMerges < ActiveRecord::Migration[5.2]
  def change
    create_table :agent_merges do |t|
      t.references :agent, foreign_key: true, null: false, type: :uuid
      t.references :agent_merge_list, null: false

      t.timestamps
    end
  end
end
