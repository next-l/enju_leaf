class AddManifestationIdToItem < ActiveRecord::Migration
  def change
    add_column :items, :manifestation_id, :integer
  end
end
