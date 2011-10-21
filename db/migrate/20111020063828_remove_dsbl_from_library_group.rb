class RemoveDsblFromLibraryGroup < ActiveRecord::Migration
  def up
    remove_column :library_groups, :use_dsbl
    remove_column :library_groups, :dsbl_list
  end

  def down
    add_column :library_groups, :dsbl_list, :text
    add_column :library_groups, :use_dsbl, :boolean
  end
end
