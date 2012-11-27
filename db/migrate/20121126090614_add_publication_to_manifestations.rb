class AddPublicationToManifestations < ActiveRecord::Migration
  def change
    add_column :manifestations, :country_of_publication_id, :integer, :default => 1, :null => false
    add_column :manifestations, :place_of_publication, :string
  end
end
