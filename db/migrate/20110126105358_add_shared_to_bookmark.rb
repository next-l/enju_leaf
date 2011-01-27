class AddSharedToBookmark < ActiveRecord::Migration
  def self.up
    add_column :bookmarks, :shared, :boolean
  end

  def self.down
    remove_column :bookmarks, :shared
  end
end
