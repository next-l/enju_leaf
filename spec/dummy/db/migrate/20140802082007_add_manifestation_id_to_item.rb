class AddManifestationIdToItem < ActiveRecord::Migration[5.2]
  def change
    add_reference :items, :manifestation
  end
end
