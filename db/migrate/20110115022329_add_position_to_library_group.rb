class AddPositionToLibraryGroup < ActiveRecord::Migration
  def self.up
    add_column :library_groups, :position, :integer
  end

  def self.down
    remove_column :library_groups, :position
  end
end
