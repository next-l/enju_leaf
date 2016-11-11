class AddOpeningHourToLibrary < ActiveRecord::Migration
  def self.up
    add_column :libraries, :opening_hour, :text
  end

  def self.down
    remove_column :libraries, :opening_hour
  end
end
