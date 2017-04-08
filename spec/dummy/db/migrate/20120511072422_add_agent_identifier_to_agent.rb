class AddAgentIdentifierToAgent < ActiveRecord::Migration[5.0]
  def change
    add_column :agents, :agent_identifier, :string
    add_index :agents, :agent_identifier
  end
end
