class CreateManifestationRelationshipTypes < ActiveRecord::Migration
  def self.up
    create_table :manifestation_relationship_types do |t|
      t.string :name
      t.text :display_name
      t.text :note
      t.integer :position

      t.timestamps
    end
  end

  def self.down
    drop_table :manifestation_relationship_types
  end
end
