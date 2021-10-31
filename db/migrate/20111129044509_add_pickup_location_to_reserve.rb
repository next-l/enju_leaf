class AddPickupLocationToReserve < ActiveRecord::Migration[4.2]
  def change
    add_column :reserves, :pickup_location_id, :integer
    add_index :reserves, :pickup_location_id
  end
end
