class CreateAgentMergeLists < ActiveRecord::Migration[5.1]
  def change
    create_table :agent_merge_lists do |t|
      t.string :title

      t.timestamps
    end
  end
end
