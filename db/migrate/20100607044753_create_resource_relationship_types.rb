class CreateResourceRelationshipTypes < ActiveRecord::Migration
  def self.up
    create_table :resource_relationship_types do |t|
      t.string :name
      t.text :display_name
      t.text :note
      t.integer :position

      t.timestamps
    end
  end

  def self.down
    drop_table :resource_relationship_types
  end
end
