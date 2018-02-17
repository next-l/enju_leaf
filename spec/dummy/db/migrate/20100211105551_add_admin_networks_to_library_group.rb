class AddAdminNetworksToLibraryGroup < ActiveRecord::Migration[5.1]
  def self.up
    add_column :library_groups, :admin_networks, :text
  end

  def self.down
    remove_column :library_groups, :admin_networks
  end
end
