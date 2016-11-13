class AddLatitudeAndLongitudeToLibrary < ActiveRecord::Migration
  def change
    add_column :libraries, :latitude, :float
    add_column :libraries, :longitude, :float
  end
end
