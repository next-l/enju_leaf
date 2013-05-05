class AddManifestationIdToSubject < ActiveRecord::Migration
  def change
    add_column :subjects, :manifestation_id, :integer
    add_index :subjects, :manifestation_id
  end
end
