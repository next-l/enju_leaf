class AddLatitudeAndLongitudeToLibrary < ActiveRecord::Migration
  def self.up
    add_column :libraries, :latitude, :float
    add_column :libraries, :longitude, :float
  end

  def self.down
    remove_column :libraries, :longitude
    remove_column :libraries, :latitude
  end
end
