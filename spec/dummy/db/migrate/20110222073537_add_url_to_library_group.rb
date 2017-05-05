class AddUrlToLibraryGroup < ActiveRecord::Migration
  def self.up
    add_column :library_groups, :url, :string, :default => 'http://localhost:3000/'
  end

  def self.down
    remove_column :library_groups, :url
  end
end
