class AddPriceStringToManifestations < ActiveRecord::Migration
  def change
    add_column :manifestations, :price_string, :string
  end
end
