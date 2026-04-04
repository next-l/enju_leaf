class AddNotNullToTitleOnBookmarks < ActiveRecord::Migration[7.2]
  def change
    Bookmark.where(shared: nil).each do |bookmark|
      bookmark.update_column(:shared, false)
    end

    change_column_null :bookmarks, :title, false
    change_column_null :bookmarks, :shared, false
    change_column_null :bookmarks, :url, false
    change_column_default :bookmarks, :shared, false
  end
end
