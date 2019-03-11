class CreateAgentMergeLists < ActiveRecord::Migration[5.2]
  def change
    create_table :agent_merge_lists, id: :uuid do |t|
      t.string :title

      t.timestamps
    end
  end
end
