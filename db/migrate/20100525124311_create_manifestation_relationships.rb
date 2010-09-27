class CreateManifestationRelationships < ActiveRecord::Migration
  def self.up
    create_table :manifestation_relationships do |t|
      t.integer :parent_id
      t.integer :child_id
      t.integer :manifestation_relationship_type_id

      t.timestamps
    end
    add_index :manifestation_relationships, :parent_id
    add_index :manifestation_relationships, :child_id
  end

  def self.down
    drop_table :manifestation_relationships
  end
end
