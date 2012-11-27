class AddManifestationTypeIdToManifestation < ActiveRecord::Migration
  def change
    add_column :manifestations, :manifestation_type_id, :integer
  end
end
