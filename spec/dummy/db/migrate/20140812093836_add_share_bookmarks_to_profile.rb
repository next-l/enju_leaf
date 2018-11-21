class AddShareBookmarksToProfile < ActiveRecord::Migration[5.1]
  def change
    add_column :profiles, :share_bookmarks, :boolean
  end
end
