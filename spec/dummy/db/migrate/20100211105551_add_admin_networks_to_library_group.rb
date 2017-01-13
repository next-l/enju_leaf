class AddAdminNetworksToLibraryGroup < ActiveRecord::Migration
  def self.up
    add_column :library_groups, :admin_networks, :cidr
  end

  def self.down
    remove_column :library_groups, :admin_networks
  end
end
