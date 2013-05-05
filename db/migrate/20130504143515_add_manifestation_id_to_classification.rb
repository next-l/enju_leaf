class AddManifestationIdToClassification < ActiveRecord::Migration
  def change
    add_column :classifications, :manifestation_id, :integer
    add_index :classifications, :manifestation_id
  end
end
