class AddAdminNetworksToLibraryGroup < ActiveRecord::Migration[4.2]
  def up
    add_column :library_groups, :admin_networks, :text
  end

  def down
    remove_column :library_groups, :admin_networks
  end
end
