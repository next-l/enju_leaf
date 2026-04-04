class AddNotNullToChildIdOnAgentRelationships < ActiveRecord::Migration[7.2]
  def change
    AgentRelationship.find_each do |agent_relationship|
      agent_relationship.destroy unless agent_relationship.child
      agent_relationship.destroy unless agent_relationship.parent
    end
    change_column_null :agent_relationships, :child_id, false
    change_column_null :agent_relationships, :parent_id, false
    change_column_null :agent_relationships, :agent_relationship_type_id, false
    add_foreign_key :agent_relationships, :agents, column: :child_id
    add_foreign_key :agent_relationships, :agents, column: :parent_id
    add_foreign_key :agent_relationships, :agent_relationship_types

    ManifestationRelationship.find_each do |manifestation_relationship|
      manifestation_relationship.destroy unless manifestation_relationship.child
      manifestation_relationship.destroy unless manifestation_relationship.parent
    end
    change_column_null :manifestation_relationships, :child_id, false
    change_column_null :manifestation_relationships, :parent_id, false
    change_column_null :manifestation_relationships, :manifestation_relationship_type_id, false
    add_foreign_key :manifestation_relationships, :manifestations, column: :child_id
    add_foreign_key :manifestation_relationships, :manifestations, column: :parent_id
    add_foreign_key :manifestation_relationships, :manifestation_relationship_types
  end
end
