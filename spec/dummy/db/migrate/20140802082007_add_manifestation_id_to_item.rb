class AddManifestationIdToItem < ActiveRecord::Migration[5.0]
  def change
    add_reference :items, :manifestation, type: :uuid, foreign_key: true
  end
end
