class AddAgentIdentifierToAgent < ActiveRecord::Migration[4.2]
  def change
    add_column :agents, :agent_identifier, :string
    add_index :agents, :agent_identifier
  end
end
