class AddStateIndexToReserve < ActiveRecord::Migration
  def change
    add_index :reserves, :state
  end
end
