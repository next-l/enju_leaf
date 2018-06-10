class AddShareBookmarksToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :share_bookmarks, :boolean
  end
end
