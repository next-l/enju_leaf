class CreateManifestationRelationships < ActiveRecord::Migration[5.0]
  def change
    create_table :manifestation_relationships do |t|
      t.uuid :parent_id, index: true
      t.uuid :child_id, index: true
      t.references :manifestation_relationship_type, index: {name: 'index_manifestation_relationships_on_relationship_type_id'}

      t.timestamps
    end
  end
end
