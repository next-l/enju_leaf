class AddLatitudeAndLongitudeToLibrary < ActiveRecord::Migration
  def self.up
    add_column :libraries, :latitude, :decimal
    add_column :libraries, :longitude, :decimal
  end

  def self.down
    remove_column :libraries, :longitude
    remove_column :libraries, :latitude
  end
end
