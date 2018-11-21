class CreateAgentRelationships < ActiveRecord::Migration[5.1]
  def change
    create_table :agent_relationships do |t|
      t.references :parent, foreign_key: {to_table: :agents}, type: :uuid, null: false
      t.references :child, foreign_key: {to_table: :agents}, type: :uuid, null: false
      t.references :agent_relationship_type, foreign_key: true, null: false

      t.timestamps
    end
  end
end
