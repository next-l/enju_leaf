class AddShareBookmarksToProfile < ActiveRecord::Migration[5.0]
  def change
    add_column :profiles, :share_bookmarks, :boolean
  end
end
