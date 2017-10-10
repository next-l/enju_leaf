class CreateAgentRelationshipTypes < ActiveRecord::Migration[5.1]
  def change
    create_table :agent_relationship_types do |t|
      t.string :name, :null => false
      t.text :display_name
      t.text :note
      t.integer :position

      t.timestamps
    end
  end
end
