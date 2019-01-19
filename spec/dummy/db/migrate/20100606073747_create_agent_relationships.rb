class CreateAgentRelationships < ActiveRecord::Migration[5.2]
  def change
    create_table :agent_relationships do |t|
      t.references :parent, foreign_key: {to_table: :agents}, null: false
      t.references :child, foreign_key: {to_table: :agents}, null: false
      t.references :agent_relationship_type, index: false

      t.timestamps
    end
  end
end
