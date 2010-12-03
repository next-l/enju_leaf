class RenameManifestationIdentifierToIdentifier < ActiveRecord::Migration
  def self.up
    rename_column :manifestations, :manifestation_identifier, :identifier
  end

  def self.down
    rename_column :manifestations, :identifier, :manifestation_identifier
  end
end
