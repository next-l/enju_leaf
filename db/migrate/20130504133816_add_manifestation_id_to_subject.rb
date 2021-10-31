class AddManifestationIdToSubject < ActiveRecord::Migration[4.2]
  def change
    add_column :subjects, :manifestation_id, :integer
    add_index :subjects, :manifestation_id
  end
end
