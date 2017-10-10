class CreateAgentMergeLists < ActiveRecord::Migration[5.1]
  def self.up
    create_table :agent_merge_lists do |t|
      t.string :title

      t.timestamps
    end
  end

  def self.down
    drop_table :agent_merge_lists
  end
end
