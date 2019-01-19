class AddPickupLocationToReserve < ActiveRecord::Migration[5.2]
  def change
    add_reference :reserves, :pickup_location, foreign_key: {to_table: :libraries}
  end
end
