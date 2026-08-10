class AddAllowBookmarkExternalUrlToLibraryGroup < ActiveRecord::Migration[4.2]
  def up
    add_column :library_groups, :allow_bookmark_external_url, :boolean, null: false, default: false, if_not_exists: true
  end

  def down
    remove_column :library_groups, :allow_bookmark_external_url
  end
end
