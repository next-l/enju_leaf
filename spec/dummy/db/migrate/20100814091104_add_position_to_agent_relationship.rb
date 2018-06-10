class AddPositionToAgentRelationship < ActiveRecord::Migration[4.2]
  def self.up
    add_column :manifestation_relationships, :position, :integer
    add_column :agent_relationships, :position, :integer
  end

  def self.down
    remove_column :agent_relationships, :position
    remove_column :manifestation_relationships, :position
  end
end
