class AddPickupLocationToReserve < ActiveRecord::Migration[5.1]
  def change
    add_reference :reserves, :pickup_location, foreign_key: {to_table: :libraries}, null: false, type: :uuid
  end
end
