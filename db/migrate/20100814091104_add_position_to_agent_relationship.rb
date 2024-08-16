class AddPositionToAgentRelationship < ActiveRecord::Migration[4.2]
  def up
    add_column :manifestation_relationships, :position, :integer
    add_column :agent_relationships, :position, :integer
  end

  def down
    remove_column :agent_relationships, :position
    remove_column :manifestation_relationships, :position
  end
end
