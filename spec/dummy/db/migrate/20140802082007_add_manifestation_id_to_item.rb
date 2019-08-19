class AddManifestationIdToItem < ActiveRecord::Migration[5.2]
  def change
    add_column :items, :manifestation_id, :integer
    add_index :items, :manifestation_id
  end
end
