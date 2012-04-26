class AddUniqueIndexToManifestationIdentifier < ActiveRecord::Migration
  def up
    remove_index :manifestations, :manifestation_identifier
    add_index :manifestations, :manifestation_identifier, :unique => true
  end

  def down
    remove_index :manifestations, :manifestation_identifier
    add_index :manifestations, :manifestation_identifier
  end
end
