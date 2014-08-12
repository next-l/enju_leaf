class AddShareBookmarksToProfile < ActiveRecord::Migration
  def change
    add_column :profiles, :share_bookmarks, :boolean
  end
end
