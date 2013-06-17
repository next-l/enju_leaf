class AddIndexManifestationTypeIdToManifestations < ActiveRecord::Migration
  def change
    add_index  :manifestations, :manifestation_type_id
  end
end
