class AddAdminNetworksToLibraryGroup < ActiveRecord::Migration[4.2]
  def self.up
    add_column :library_groups, :admin_networks, :text
  end

  def self.down
    remove_column :library_groups, :admin_networks
  end
end
