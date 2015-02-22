class AddAllowBookmarkExternalUrlToLibraryGroup < ActiveRecord::Migration
  def self.up
    add_column :library_groups, :allow_bookmark_external_url, :boolean, :null => false, :default => false
  end

  def self.down
    remove_column :library_groups, :allow_bookmark_external_url
  end
end
