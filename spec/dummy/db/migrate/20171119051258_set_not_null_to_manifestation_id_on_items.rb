class SetNotNullToManifestationIdOnItems < ActiveRecord::Migration[5.2]
  def change
    change_column_null :items, :manifestation_id, false
  end
end
