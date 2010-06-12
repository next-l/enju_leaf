class CreateResourceRelationships < ActiveRecord::Migration
  def self.up
    create_table :resource_relationships do |t|
      t.integer :parent_id
      t.integer :child_id
      t.integer :resource_relationship_type_id

      t.timestamps
    end
    add_index :resource_relationships, :parent_id
    add_index :resource_relationships, :child_id
  end

  def self.down
    drop_table :resource_relationships
  end
end
