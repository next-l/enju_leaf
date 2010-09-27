class AddPositionToPatronRelationship < ActiveRecord::Migration
  def self.up
    add_column :manifestation_relationships, :position, :integer
    add_column :patron_relationships, :position, :integer
  end

  def self.down
    remove_column :patron_relationships, :position
    remove_column :manifestation_relationships, :position
  end
end
