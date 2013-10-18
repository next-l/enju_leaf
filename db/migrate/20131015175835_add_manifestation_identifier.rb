class AddManifestationIdentifier < ActiveRecord::Migration
  def up
    add_column :manifestations, :manifestation_identifier, :string
  end

  def down
    remove_column :manifestations, :manifestation_identifier
  end
end
