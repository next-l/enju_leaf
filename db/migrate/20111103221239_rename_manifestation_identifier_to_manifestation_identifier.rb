class RenameManifestationIdentifierToManifestationIdentifier < ActiveRecord::Migration
  def up
    rename_column :manifestations, :identifier, :manifestation_identifier
  end

  def down
    rename_column :manifestations, :manifestation_identifier, :identifier
  end
end
