class AddShareBookmarksToUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :share_bookmarks, :boolean
  end
end
