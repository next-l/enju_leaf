class CreateAgentMergeLists < ActiveRecord::Migration[4.2]
  def up
    create_table :agent_merge_lists do |t|
      t.string :title

      t.timestamps
    end
  end

  def down
    drop_table :agent_merge_lists
  end
end
