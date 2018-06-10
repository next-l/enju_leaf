class AddManifestationIdToItem < ActiveRecord::Migration[4.2]
  def change
    add_column :items, :manifestation_id, :integer
    add_index :items, :manifestation_id
  end
end
