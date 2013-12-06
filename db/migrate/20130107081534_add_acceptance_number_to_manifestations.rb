class AddAcceptanceNumberToManifestations < ActiveRecord::Migration
  def change
    add_column :manifestations, :acceptance_number, :integer
  end
end
