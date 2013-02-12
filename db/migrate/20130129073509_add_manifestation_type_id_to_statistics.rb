class AddManifestationTypeIdToStatistics < ActiveRecord::Migration
  def change
    add_column :statistics, :manifestation_type_id, :integer
  end
end
