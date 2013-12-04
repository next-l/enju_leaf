class CreateRelationshipFamilies < ActiveRecord::Migration
  def change
    create_table :relationship_families do |t|
      t.string :fid
      t.string :display_name, :null => false
      t.text :description
      t.text :note

      t.timestamps
    end
  end
end
