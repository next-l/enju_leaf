class AddAdminNetworksToLibraryGroup < ActiveRecord::Migration[5.0]
  def self.up
    add_column :library_groups, :admin_networks, :cidr
  end

  def self.down
    remove_column :library_groups, :admin_networks
  end
end
