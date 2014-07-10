class AddAgentIdentifierToAgent < ActiveRecord::Migration
  def change
    add_column :agents, :agent_identifier, :string
    add_index :agents, :agent_identifier
  end
end
