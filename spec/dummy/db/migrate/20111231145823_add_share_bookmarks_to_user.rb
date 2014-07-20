class AddShareBookmarksToUser < ActiveRecord::Migration
  def change
    add_column :users, :share_bookmarks, :boolean
  end
end
