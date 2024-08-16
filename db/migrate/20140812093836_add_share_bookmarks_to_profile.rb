class AddShareBookmarksToProfile < ActiveRecord::Migration[4.2]
  def up
    add_column :profiles, :share_bookmarks, :boolean, if_not_exists: true
  end

  def down
    remove_column :profiles, :share_bookmarks
  end
end
