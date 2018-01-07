class SetNotNullToManifestationIdOnItems < ActiveRecord::Migration
  def change
    change_column_null :items, :manifestation_id, false
  end
end
